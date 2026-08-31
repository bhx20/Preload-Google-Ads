import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preload_google_ads/preload_google_ads.dart';
import 'package:preload_google_ads/src/ad_internal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Banner Ad & Collapsible Banner Tests', () {
    test('LoadBannerAd singleton properties and reload scheduling', () async {
      final loader = LoadBannerAd.instance;
      loader.reset();

      expect(loader.adLabel, "Banner");
      expect(loader.isEnabled, isTrue);
      expect(loader.bannerAdObject, isEmpty);

      bool timerFired = false;
      loader.scheduleReload(const Duration(milliseconds: 100), () {
        timerFired = true;
      });

      loader.reset();
      await Future.delayed(const Duration(milliseconds: 120));
      expect(timerFired, isFalse, reason: 'Reload timers must be cancelled on reset.');
    });

    test('ShowBannerAd and ShowCollapsibleBannerAd widget constructors', () {
      const widgetStandard = ShowBannerAd();
      expect(widgetStandard, isA<Widget>());

      const widgetCollapsibleBottom = ShowCollapsibleBannerAd(
        collapsiblePosition: CollapsibleBannerPosition.bottom,
      );
      expect(widgetCollapsibleBottom.collapsiblePosition, equals(CollapsibleBannerPosition.bottom));

      const widgetCollapsibleTop = ShowCollapsibleBannerAd(
        collapsiblePosition: CollapsibleBannerPosition.top,
      );
      expect(widgetCollapsibleTop.collapsiblePosition, equals(CollapsibleBannerPosition.top));
    });
  });
}
