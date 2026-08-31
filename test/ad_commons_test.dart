import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preload_google_ads/preload_google_ads.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdConfigData & CustomNativeADStyle Tests', () {
    test('AdConfigData constructs with custom parameters and defaults', () {
      final config = AdConfigData(
        adIDs: AdIDS(
          appOpenId: 'test_app_open',
          bannerId: 'test_banner',
          nativeId: 'test_native',
          interstitialId: 'test_interstitial',
          rewardedId: 'test_rewarded',
          rewardedInterstitialId: 'test_rewarded_interstitial',
        ),
        themeMode: AdThemeMode.dark,
      );

      expect(config.adIDs?.appOpenId, equals('test_app_open'));
      expect(config.adIDs?.bannerId, equals('test_banner'));
      expect(config.adIDs?.nativeId, equals('test_native'));
      expect(config.adIDs?.interstitialId, equals('test_interstitial'));
      expect(config.adIDs?.rewardedId, equals('test_rewarded'));
      expect(config.adIDs?.rewardedInterstitialId, equals('test_rewarded_interstitial'));
      expect(config.themeMode, equals(AdThemeMode.dark));
    });

    test('CustomNativeADStyle light and dark constructors', () {
      final lightStyle = CustomNativeADStyle(
        titleColor: const Color(0xFF111111),
        bodyColor: const Color(0xFF222222),
        buttonBackground: const Color(0xFF333333),
        buttonForeground: const Color(0xFFFFFFFF),
        tagBackground: const Color(0xFF444444),
        tagForeground: const Color(0xFFFFFFFF),
        buttonRadius: 8,
        tagRadius: 4,
        buttonGradients: const [Color(0xFF333333), Color(0xFF444444)],
      );

      expect(lightStyle.titleColor, equals(const Color(0xFF111111)));
      expect(lightStyle.buttonRadius, equals(8));
      expect(lightStyle.buttonGradients.length, equals(2));

      final darkStyle = CustomNativeADStyle.dark(
        titleColor: const Color(0xFFFFFFFF),
        bodyColor: const Color(0xFFEEEEEE),
      );

      expect(darkStyle.titleColor, equals(const Color(0xFFFFFFFF)));
      expect(darkStyle.bodyColor, equals(const Color(0xFFEEEEEE)));
    });
  });
}
