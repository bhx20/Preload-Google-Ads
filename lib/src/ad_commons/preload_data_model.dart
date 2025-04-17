import '../../preload_google_ads.dart';

/// Configuration data for all ad-related settings.
class AdConfigData {
  /// IDs for various ad formats.
  final AdIDS? adIDs;

  /// Controls ad display counters.
  final AdCounter? adCounter;

  /// Toggles for showing/hiding different types of ads.
  final AdFlag? adFlag;

  /// Styling preferences for ads.
  final NativeAdStyle? adStyle;

  final NativeAdLayout nativeAdLayout;
  /// Constructor for [AdConfigData].
  AdConfigData({this.adIDs, this.adCounter, this.adFlag, this.adStyle,this.nativeAdLayout=NativeAdLayout.nativeLayout});
}

/// Contains Ad Unit IDs for different ad types.
class AdIDS {
  /// App open ad ID.
  final String? appOpenId;

  /// Banner ad ID.
  final String? bannerId;

  /// Native ad ID.
  final String? nativeId;

  /// Interstitial ad ID.
  final String? interstitialId;

  /// Rewarded ad ID.
  final String? rewardedId;

  /// Constructor for [AdIDS].
  AdIDS({
    this.appOpenId,
    this.bannerId,
    this.nativeId,
    this.interstitialId,
    this.rewardedId,
  });
}

/// Controls the display frequency of ads using counters.
class AdCounter {
  /// Number of times to show interstitial ads.
  final int? interstitialCounter;

  /// Number of times to show rewarded ads.
  final int? rewardedCounter;

  /// Number of times to show native ads.
  final int? nativeCounter;

  /// Constructor for [AdCounter].
  AdCounter({
    this.interstitialCounter,
    this.rewardedCounter,
    this.nativeCounter,
  });
}

/// Flags to enable/disable various ad types.
class AdFlag {
  /// Master flag to show/hide all ads.
  final bool? showAd;

  /// Show banner ads.
  final bool? showBanner;

  /// Show interstitial ads.
  final bool? showInterstitial;

  /// Show native ads.
  final bool? showNative;

  /// Show splash screen ad.
  final bool? showSplashAd;

  /// Show open app ad.
  final bool? showOpenApp;

  /// Show rewarded ad.
  final bool? showRewarded;

  /// Constructor for [AdFlag].
  AdFlag({
    this.showAd,
    this.showBanner,
    this.showInterstitial,
    this.showNative,
    this.showSplashAd,
    this.showOpenApp,
    this.showRewarded,
  });
}






/// Styling configuration for ad components.
class NativeAdStyle {
  /// Color of the ad title text.
  Color titleColor;

  /// Color of the ad body text.
  Color bodyColor;

  /// Background color of ad tags.
  Color tagBackground;

  /// Foreground color (text/icon) of ad tags.
  Color tagForeground;

  /// Background color of ad buttons.
  Color buttonBackground;

  /// Foreground color (text/icon) of ad buttons.
  Color buttonForeground;

  /// Border radius for ad buttons.
  int buttonRadius;

  /// Border radius for ad tags.
  int tagRadius;

  /// Optional gradient colors for ad buttons.
  List<Color> buttonGradients;

  /// Constructor for [NativeAdStyle] with default styling values.
  NativeAdStyle({
    this.titleColor = const Color(0xFF000000),
    this.bodyColor = const Color(0xFF808080),
    this.tagBackground = const Color(0xFFF19938),
    this.tagForeground = const Color(0xFFFFFFFF),
    this.buttonBackground = const Color(0xFF2196F3),
    this.buttonForeground = const Color(0xFFFFFFFF),
    this.buttonRadius = 5,
    this.tagRadius = 5,
    List<Color>? buttonGradients,
  }) : buttonGradients = buttonGradients ?? [];
}
