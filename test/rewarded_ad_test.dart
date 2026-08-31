import 'package:flutter_test/flutter_test.dart';
import 'package:preload_google_ads/src/ad_internal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Rewarded & Rewarded Interstitial Ad Tests', () {
    test('RewardAd initial properties & limit checking', () {
      final loader = RewardAd.instance;
      loader.reset();

      expect(loader.adLabel, "Rewarded");
      expect(loader.isEnabled, isTrue);
      expect(loader.state, AdLoadState.initial);

      loader.state = AdLoadState.loading;
      expect(loader.canShowAd(2), isFalse);
      expect(loader.counter, 1);

      expect(loader.canShowAd(2), isFalse);
      expect(loader.counter, 2);

      loader.state = AdLoadState.ready;
      expect(loader.canShowAd(2), isTrue);
    });

    test('RewardInterAd initial properties & lifecycle', () {
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
  });
}
