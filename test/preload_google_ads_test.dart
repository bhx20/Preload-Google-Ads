import 'package:flutter_test/flutter_test.dart';
import 'package:preload_google_ads/src/ad_internal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdLoadState Enum & Getters', () {
    test('AdLoaderMixin state getters reflect AdLoadState accurately', () {
      final loader = InterAd.instance;
      loader.reset();

      loader.state = AdLoadState.initial;
      expect(loader.isAdLoaded, isFalse);
      expect(loader.isLoading, isFalse);
      expect(loader.isShowing, isFalse);
      expect(loader.isFailed, isFalse);

      loader.state = AdLoadState.loading;
      expect(loader.isLoading, isTrue);

      loader.state = AdLoadState.ready;
      expect(loader.isAdLoaded, isTrue);

      loader.state = AdLoadState.showing;
      expect(loader.isShowing, isTrue);

      loader.state = AdLoadState.failed;
      expect(loader.isFailed, isTrue);
    });

    test('AdLoaderMixin legacy setter compatibility', () {
      final loader = InterAd.instance;
      loader.reset();

      loader.isAdLoaded = true;
      expect(loader.state, AdLoadState.ready);

      loader.isAdLoaded = false;
      expect(loader.state, AdLoadState.initial);
    });
  });

  group('AdStats Tracking', () {
    test('AdStats instance correctly tracks counters', () {
      final stats = AdStats.instance;
      stats.interLoad.value = 0;
      stats.interImp.value = 0;

      stats.interLoad.value++;
      expect(stats.interLoad.value, 1);

      stats.interImp.value++;
      expect(stats.interImp.value, 1);
    });
  });

  group('PreloadGoogleAds & Config Tests', () {
    test('PreloadGoogleAds singleton instance is consistent', () {
      final instance1 = PreloadGoogleAds.instance;
      final instance2 = PreloadGoogleAds.instance;
      expect(instance1, same(instance2));
      expect(PreloadGoogleAds.instance, isNotNull);
    });

    test('AdManager config defaults to preData correctly', () {
      expect(AdManager.instance.config, isNotNull);
    });

    test('AdConfigData default setup', () {
      final config = AdConfigData(
        adIDs: AdIDS(
          appOpenId: 'test_app_open',
          bannerId: 'test_banner',
        ),
      );
      expect(config.adIDs?.appOpenId, 'test_app_open');
      expect(config.adIDs?.bannerId, 'test_banner');
    });
  });

  group('Interstitial Ad Loader (InterAd) Tests', () {
    test('InterAd initial state and properties', () {
      final loader = InterAd.instance;
      loader.reset();

      expect(loader.adLabel, "Interstitial");
      expect(loader.isEnabled, isTrue);
      expect(loader.state, AdLoadState.initial);
      expect(loader.counter, 0);
      expect(loader.retryAttempts, 3);
    });

    test('InterAd prepareLoad transitions state to loading', () {
      final loader = InterAd.instance;
      loader.reset();

      expect(loader.prepareLoad(), isTrue);
      expect(loader.state, AdLoadState.loading);
      expect(loader.prepareLoad(), isFalse, reason: 'Duplicate load requests while loading must be ignored.');
    });

    test('InterAd handleLoadSuccess updates state and retries', () {
      final loader = InterAd.instance;
      loader.reset();
      loader.state = AdLoadState.loading;

      loader.handleLoadSuccess();
      expect(loader.state, AdLoadState.ready);
      expect(loader.isAdLoaded, isTrue);
      expect(loader.retryAttempts, 3);
    });

    test('InterAd handleFailureAndRetry decrements retry attempts', () {
      final loader = InterAd.instance;
      loader.reset();

      bool retryCalled = false;
      loader.handleFailureAndRetry('error', onRetry: () {
        retryCalled = true;
      });

      expect(loader.retryAttempts, 2);
      expect(retryCalled, isTrue);
    });

    test('InterAd reset restores all properties to default', () {
      final loader = InterAd.instance;
      loader.state = AdLoadState.ready;
      loader.counter = 5;

      loader.reset();
      expect(loader.state, AdLoadState.initial);
      expect(loader.counter, 0);
    });
  });

  group('Rewarded Ad Loader (RewardAd) Tests', () {
    test('RewardAd initial properties', () {
      final loader = RewardAd.instance;
      loader.reset();

      expect(loader.adLabel, "Rewarded");
      expect(loader.isEnabled, isTrue);
      expect(loader.state, AdLoadState.initial);
    });

    test('RewardAd canShowAd limit checking', () {
      final loader = RewardAd.instance;
      loader.reset();

      // Ensure state is loading so calling canShowAd does not try to invoke native MethodChannel in tests
      loader.state = AdLoadState.loading;

      expect(loader.canShowAd(2), isFalse);
      expect(loader.counter, 1);

      expect(loader.canShowAd(2), isFalse);
      expect(loader.counter, 2);

      loader.state = AdLoadState.ready;
      expect(loader.canShowAd(2), isTrue);
    });
  });

  group('Native Ad Loaders (LoadMediumNative & LoadSmallNative) Tests', () {
    test('LoadMediumNative properties and reload timer cancellation', () async {
      final loader = LoadMediumNative.instance;
      loader.reset();

      expect(loader.adLabel, "Medium Native");
      expect(loader.isEnabled, isTrue);
      expect(loader.ads, isEmpty);

      bool timerFired = false;
      loader.scheduleReload(const Duration(milliseconds: 100), () {
        timerFired = true;
      });

      loader.reset();
      await Future.delayed(const Duration(milliseconds: 120));
      expect(timerFired, isFalse, reason: 'Pending reload timer must be cancelled on reset.');
    });

    test('LoadSmallNative properties and counter tracking', () {
      final loader = LoadSmallNative.instance;
      loader.reset();

      expect(loader.adLabel, "Small Native");
      expect(loader.isEnabled, isTrue);
      expect(loader.counter, 0);
      expect(loader.reloadAdCount, 3);

      loader.incrementCounter();
      expect(loader.counter, 1);

      loader.resetCounter();
      expect(loader.counter, 0);
    });
  });

  group('Banner Ad Loader (LoadBannerAd) Tests', () {
    test('LoadBannerAd properties and memory reset', () async {
      final loader = LoadBannerAd.instance;
      loader.reset();

      expect(loader.adLabel, "Banner");
      expect(loader.isEnabled, isTrue);
      expect(loader.bannerAdObject, isEmpty);
      expect(loader.loading, isFalse);

      bool timerFired = false;
      loader.scheduleReload(const Duration(milliseconds: 100), () {
        timerFired = true;
      });

      loader.reset();
      await Future.delayed(const Duration(milliseconds: 120));
      expect(timerFired, isFalse);
    });

    test('ShowBannerAd widget supports collapsible banner parameter', () {
      const widgetStandard = ShowBannerAd();
      expect(widgetStandard.isCollapsible, isNull);

      const widgetCollapsibleBottom = ShowBannerAd(isCollapsible: 'bottom');
      expect(widgetCollapsibleBottom.isCollapsible, 'bottom');

      const widgetCollapsibleTop = ShowBannerAd(isCollapsible: 'top');
      expect(widgetCollapsibleTop.isCollapsible, 'top');
    });
  });

  group('App Open Ad Manager (AppOpenAdManager) Tests', () {
    test('AppOpenAdManager availability and reset', () {
      final loader = AppOpenAdManager.instance;
      loader.reset();

      expect(loader.adLabel, "App Open");
      expect(loader.isEnabled, isTrue);

      expect(loader.prepareLoad(), isTrue);
      expect(loader.state, AdLoadState.loading);

      loader.handleLoadSuccess();
      expect(loader.state, AdLoadState.ready);

      loader.reset();
      expect(loader.state, AdLoadState.initial);
      expect(loader.isAdAvailable, isFalse);
    });
  });

  group('Rewarded Interstitial Ad Loader (RewardInterAd) Tests', () {
    test('RewardInterAd initial properties and lifecycle', () {
      final loader = RewardInterAd.instance;
      loader.reset();

      expect(loader.adLabel, "Rewarded Interstitial");
      expect(loader.isEnabled, isTrue);
      expect(loader.state, AdLoadState.initial);
      expect(loader.retryAttempts, 3);

      expect(loader.prepareLoad(), isTrue);
      expect(loader.state, AdLoadState.loading);

      loader.handleLoadSuccess();
      expect(loader.isAdLoaded, isTrue);

      loader.reset();
      expect(loader.state, AdLoadState.initial);
      expect(loader.isAdLoaded, isFalse);
    });

    test('RewardInterAd canShowAd limit checking', () {
      final loader = RewardInterAd.instance;
      loader.reset();

      loader.state = AdLoadState.loading;

      expect(loader.canShowAd(2), isFalse);
      expect(loader.counter, 1);

      expect(loader.canShowAd(2), isFalse);
      expect(loader.counter, 2);

      loader.state = AdLoadState.ready;
      expect(loader.canShowAd(2), isTrue);
    });
  });
}
