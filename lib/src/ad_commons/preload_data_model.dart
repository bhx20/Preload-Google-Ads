import '../ad_internal.dart';

/// Enum representing the ad theme mode.
enum AdThemeMode {
  /// Automatically matches system / Flutter ThemeData brightness.
  system,

  /// Forces Light Mode ad styles.
  light,

  /// Forces Dark Mode ad styles.
  dark,
}

/// Configuration data for all ad-related settings.
class AdConfigData {
  /// IDs for various ad formats.
  final AdIDS? adIDs;

  /// Controls ad display counters.
  final AdCounter? adCounter;

  /// Toggles for showing/hiding different types of ads.
  final AdFlag? adFlag;

  /// Styling preferences for native ads (Light and Dark mode support).
  final NativeADLayout? nativeADLayout;

  /// Styling preferences for banner ads (Light and Dark mode support).
  final BannerADLayout? bannerADLayout;

  /// Theme mode for ad styling (system, light, or dark).
  final AdThemeMode themeMode;

  /// Constructor for [AdConfigData].
  AdConfigData({
    this.adIDs,
    this.adCounter,
    this.adFlag,
    this.nativeADLayout,
    this.bannerADLayout,
    this.themeMode = AdThemeMode.system,
  });
}

/// Configuration for the layout of banner ads.
class BannerADLayout {
  /// The decoration of the container surrounding the banner ad in Light Mode.
  BoxDecoration? lightDecoration;

  /// Legacy alias getter for [lightDecoration] for backward compatibility.
  BoxDecoration? get decoration => lightDecoration;

  /// Legacy alias setter for [lightDecoration] for backward compatibility.
  set decoration(BoxDecoration? value) => lightDecoration = value;

  /// The decoration of the container surrounding the banner ad in Dark Mode.
  BoxDecoration? darkDecoration;

  /// The padding of the container surrounding the banner ad.
  EdgeInsets? padding;

  /// The margin of the container surrounding the banner ad.
  EdgeInsets? margin;

  /// Constructor for [BannerADLayout] with Light Mode and Dark Mode decoration options.
  BannerADLayout({
    BoxDecoration? lightDecoration,
    BoxDecoration? decoration,
    this.darkDecoration,
    this.padding,
    this.margin,
  }) : lightDecoration = lightDecoration ?? decoration;
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

  /// Rewarded Interstitial ad ID.
  final String? rewardedInterstitialId;

  /// Constructor for [AdIDS].
  AdIDS({
    this.appOpenId,
    this.bannerId,
    this.nativeId,
    this.interstitialId,
    this.rewardedId,
    this.rewardedInterstitialId,
  });
}

/// Controls the display frequency of ads using counters.
class AdCounter {
  /// Number of times to show interstitial ads.
  final int? interstitialCounter;

  /// Number of times to show rewarded ads.
  final int? rewardedCounter;

  /// Number of times to show rewarded interstitial ads.
  final int? rewardedInterstitialCounter;

  /// Number of times to show native ads.
  final int? nativeCounter;

  /// Constructor for [AdCounter].
  AdCounter({
    this.interstitialCounter,
    this.rewardedCounter,
    this.rewardedInterstitialCounter,
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

  /// Show rewarded interstitial ad.
  final bool? showRewardedInterstitial;

  /// Constructor for [AdFlag].
  AdFlag({
    this.showAd,
    this.showBanner,
    this.showInterstitial,
    this.showNative,
    this.showSplashAd,
    this.showOpenApp,
    this.showRewarded,
    this.showRewardedInterstitial,
  });
}

/// Configuration for the layout of native ads.
class NativeADLayout {
  /// The type of layout to use (Flutter or native).
  final AdLayout adLayout;

  /// Custom styling settings for native platform layouts in Light Mode.
  final CustomNativeADStyle? customNativeADStyle;

  /// Custom styling settings for native platform layouts in Dark Mode.
  final CustomNativeADStyle? darkCustomNativeADStyle;

  /// Styling settings for Flutter-based native ad templates in Light Mode.
  final FlutterNativeADStyle? flutterNativeADStyle;

  /// Styling settings for Flutter-based native ad templates in Dark Mode.
  final FlutterNativeADStyle? darkFlutterNativeADStyle;

  /// The decoration of the container surrounding the native ad in Light Mode.
  BoxDecoration lightDecoration;

  /// Legacy alias getter for [lightDecoration] for backward compatibility.
  BoxDecoration get decoration => lightDecoration;

  /// Legacy alias setter for [lightDecoration] for backward compatibility.
  set decoration(BoxDecoration value) => lightDecoration = value;

  /// The decoration of the container surrounding the native ad in Dark Mode.
  BoxDecoration? darkDecoration;

  /// The padding of the container surrounding the native ad.
  EdgeInsets padding;

  /// The margin of the container surrounding the native ad.
  EdgeInsets margin;

  /// Constructor for [NativeADLayout] with Light Mode and Dark Mode decoration options.
  NativeADLayout({
    AdLayout? adLayout,
    this.customNativeADStyle,
    this.darkCustomNativeADStyle,
    this.flutterNativeADStyle,
    this.darkFlutterNativeADStyle,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxDecoration? lightDecoration,
    BoxDecoration? decoration,
    this.darkDecoration,
  })  : adLayout = adLayout ?? AdLayout.nativeLayout,
        lightDecoration = lightDecoration ??
            decoration ??
            BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(5),
            ),
        padding = padding ?? const EdgeInsets.all(5),
        margin = margin ?? const EdgeInsets.all(5);
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

  /// The constraints for medium-sized native ads.
  BoxConstraints mediumBoxConstrain;

  /// The constraints for small-sized native ads.
  BoxConstraints smallBoxConstrain;

  /// Default Light Mode Constructor.
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

  /// Factory constructor for Dark Mode presets.
  factory CustomNativeADStyle.dark({
    Color titleColor = const Color(0xFFF8FAFC),
    Color bodyColor = const Color(0xFF94A3B8),
    Color tagBackground = const Color(0xFFF19938),
    Color tagForeground = const Color(0xFFFFFFFF),
    Color buttonBackground = const Color(0xFF6366F1),
    Color buttonForeground = const Color(0xFFFFFFFF),
    int buttonRadius = 5,
    int tagRadius = 5,
    List<Color>? buttonGradients,
    BoxConstraints? mediumBoxConstrain,
    BoxConstraints? smallBoxConstrain,
  }) {
    return CustomNativeADStyle(
      titleColor: titleColor,
      bodyColor: bodyColor,
      tagBackground: tagBackground,
      tagForeground: tagForeground,
      buttonBackground: buttonBackground,
      buttonForeground: buttonForeground,
      buttonRadius: buttonRadius,
      tagRadius: tagRadius,
      buttonGradients: buttonGradients,
      mediumBoxConstrain: mediumBoxConstrain,
      smallBoxConstrain: smallBoxConstrain,
    );
  }
}

/// Styling configuration for Flutter native ad templates.
class FlutterNativeADStyle {
  /// Text style for the call-to-action button (e.g., "Install", "Learn More").
  NativeTemplateTextStyle? callToActionTextStyle;

  /// Text style for the primary title or headline of the ad.
  NativeTemplateTextStyle? primaryTextStyle;

  /// Text style for the secondary text (typically body or rating info).
  NativeTemplateTextStyle? secondaryTextStyle;

  /// Text style for tertiary text (e.g., store name or additional info).
  NativeTemplateTextStyle? tertiaryTextStyle;

  /// Background color for the entire ad template.
  Color? mainBackgroundColor;

  /// Corner radius for call-to-action and icon elements (iOS only).
  double? cornerRadius;

  /// The constraints for medium-sized native ads in the Flutter template.
  BoxConstraints mediumBoxConstrain;

  /// The constraints for small-sized native ads in the Flutter template.
  BoxConstraints smallBoxConstrain;

  /// Default Light Mode Constructor.
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

  /// Factory constructor for Dark Mode presets.
  factory FlutterNativeADStyle.dark({
    NativeTemplateTextStyle? callToActionTextStyle,
    NativeTemplateTextStyle? primaryTextStyle,
    NativeTemplateTextStyle? secondaryTextStyle,
    NativeTemplateTextStyle? tertiaryTextStyle,
    Color mainBackgroundColor = const Color(0xFF1E293B),
    double cornerRadius = 5.0,
    BoxConstraints? mediumBoxConstrain,
    BoxConstraints? smallBoxConstrain,
  }) {
    return FlutterNativeADStyle(
      callToActionTextStyle: callToActionTextStyle ??
          NativeTemplateTextStyle(
            textColor: Colors.white,
            backgroundColor: const Color(0xFF6366F1),
            style: NativeTemplateFontStyle.bold,
            size: 14.0,
          ),
      primaryTextStyle: primaryTextStyle ??
          NativeTemplateTextStyle(
            textColor: const Color(0xFFF8FAFC),
            style: NativeTemplateFontStyle.normal,
            size: 16.0,
          ),
      secondaryTextStyle: secondaryTextStyle ??
          NativeTemplateTextStyle(
            textColor: const Color(0xFF94A3B8),
            style: NativeTemplateFontStyle.normal,
            size: 14.0,
          ),
      tertiaryTextStyle: tertiaryTextStyle ??
          NativeTemplateTextStyle(
            textColor: const Color(0xFF64748B),
            style: NativeTemplateFontStyle.normal,
            size: 12.0,
          ),
      mainBackgroundColor: mainBackgroundColor,
      cornerRadius: cornerRadius,
      mediumBoxConstrain: mediumBoxConstrain,
      smallBoxConstrain: smallBoxConstrain,
    );
  }
}
