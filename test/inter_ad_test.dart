import 'package:flutter_test/flutter_test.dart';
import 'package:preload_google_ads/src/ad_internal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InterAd Lifecycle Tests', () {
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

    test('InterAd handleLoadSuccess updates state to ready', () {
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
}
