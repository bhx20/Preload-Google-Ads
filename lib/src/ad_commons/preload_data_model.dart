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
  final NativeADLayout? nativeADLayout;

  /// Constructor for [AdConfigData].
  AdConfigData({this.adIDs, this.adCounter, this.adFlag, this.nativeADLayout});
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

class NativeADLayout {
  final AdLayout adLayout;
  final CustomNativeADStyle? customNativeADStyle;
  final FlutterNativeADStyle? flutterNativeADStyle;
  BoxDecoration decoration;

  EdgeInsets padding;

  EdgeInsets margin;

  NativeADLayout({
    AdLayout? adLayout,
    this.customNativeADStyle,
    this.flutterNativeADStyle,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxDecoration? decoration,
  })  : adLayout = adLayout ?? AdLayout.nativeLayout,
        decoration = decoration ??
            BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(5),
            ),
        padding = padding ?? EdgeInsets.all(5),
        margin = margin ?? EdgeInsets.all(5);
}

/// Styling configuration for ad components.
class CustomNativeADStyle {
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

  BoxConstraints mediumBoxConstrain;

  BoxConstraints smallBoxConstrain;

  /// Constructor for [CustomNativeADStyle] with default styling values.
  CustomNativeADStyle({
    this.titleColor = const Color(0xFF000000),
    this.bodyColor = const Color(0xFF808080),
    this.tagBackground = const Color(0xFFF19938),
    this.tagForeground = const Color(0xFFFFFFFF),
    this.buttonBackground = const Color(0xFF2196F3),
    this.buttonForeground = const Color(0xFFFFFFFF),
    this.buttonRadius = 5,
    this.tagRadius = 5,
    List<Color>? buttonGradients,
    BoxConstraints? mediumBoxConstrain,
    BoxConstraints? smallBoxConstrain,
  })  : buttonGradients = buttonGradients ?? [],
        mediumBoxConstrain = BoxConstraints(
          minWidth: 320,
          minHeight: 210,
          maxWidth: 400,
          maxHeight: 265,
        ),
        smallBoxConstrain = BoxConstraints(
          minWidth: 320,
          minHeight: 57,
          maxWidth: 400,
          maxHeight: 135,
        );
}

/// Styling configuration for Flutter native ad templates.
class FlutterNativeADStyle {
  /// Text style for the call-to-action button (e.g., "Install", "Learn More").
  ///
  /// Uses white text on a blue background by default, with bold font styling.
  NativeTemplateTextStyle? callToActionTextStyle;

  /// Text style for the primary title or headline of the ad.
  ///
  /// Defaults to black color, normal font, size 16.
  NativeTemplateTextStyle? primaryTextStyle;

  /// Text style for the secondary text (typically body or rating info).
  ///
  /// Defaults to grey color, normal font, size 14.
  NativeTemplateTextStyle? secondaryTextStyle;

  /// Text style for tertiary text (e.g., store name or additional info).
  ///
  /// Defaults to grey color, italic font, size 12.
  NativeTemplateTextStyle? tertiaryTextStyle;

  /// Background color for the entire ad template.
  ///
  /// Defaults to white.
  Color? mainBackgroundColor;

  /// Corner radius for call-to-action and icon elements (iOS only).
  ///
  /// Defaults to 5.0, matching `CustomNativeADStyle.buttonRadius`.
  double? cornerRadius;

  BoxConstraints mediumBoxConstrain;

  BoxConstraints smallBoxConstrain;

  /// Constructor that applies default styling similar to [CustomNativeADStyle].
  FlutterNativeADStyle({
    NativeTemplateTextStyle? callToActionTextStyle,
    NativeTemplateTextStyle? primaryTextStyle,
    NativeTemplateTextStyle? secondaryTextStyle,
    NativeTemplateTextStyle? tertiaryTextStyle,
    Color? mainBackgroundColor,
    double? cornerRadius,
    BoxConstraints? mediumBoxConstrain,
    BoxConstraints? smallBoxConstrain,
  })  : callToActionTextStyle = callToActionTextStyle ??
            NativeTemplateTextStyle(
              textColor: Colors.white,
              backgroundColor: Colors.blue,
              style: NativeTemplateFontStyle.bold,
              size: 14.0,
            ),
        primaryTextStyle = primaryTextStyle ??
            NativeTemplateTextStyle(
              textColor: Colors.black,
              style: NativeTemplateFontStyle.normal,
              size: 16.0,
            ),
        secondaryTextStyle = secondaryTextStyle ??
            NativeTemplateTextStyle(
              textColor: Colors.grey,
              style: NativeTemplateFontStyle.normal,
              size: 14.0,
            ),
        tertiaryTextStyle = tertiaryTextStyle ??
            NativeTemplateTextStyle(
              textColor: Colors.grey,
              style: NativeTemplateFontStyle.normal,
              size: 12.0,
            ),
        mainBackgroundColor = mainBackgroundColor ?? Colors.white,
        cornerRadius = cornerRadius ?? 5.0,
        mediumBoxConstrain = BoxConstraints(
          minWidth: 320,
          minHeight: 280,
          maxWidth: 400,
          maxHeight: 365,
        ),
        smallBoxConstrain = BoxConstraints(
          minWidth: 320,
          minHeight: 88,
          maxWidth: 400,
          maxHeight: 120,
        );
}
