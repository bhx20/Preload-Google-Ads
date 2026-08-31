import 'package:flutter_test/flutter_test.dart';
import 'package:preload_google_ads/src/ad_internal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppOpenAdManager Tests', () {
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
}
