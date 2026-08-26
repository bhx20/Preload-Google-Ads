import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preload_google_ads/preload_google_ads.dart';
import 'package:preload_google_ads/src/ad_internal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Native Ad Loaders & Widgets Tests', () {
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

    test('PreloadGoogleAds showNativeAd key wrapping', () {
      final widget = PreloadGoogleAds.instance.showNativeAd(
        key: const ValueKey("test_native_key"),
        nativeADType: NativeADType.small,
      );

      expect(widget, isA<Widget>());
      expect((widget as KeyedSubtree).key, equals(const ValueKey("test_native_key")));
    });
  });
}
