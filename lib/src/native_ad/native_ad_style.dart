import '../ad_internal.dart';

/// Singleton class responsible for managing the styling of native ads.
class NativeADStyle {
  /// Singleton instance of [NativeADStyle].
  static final NativeADStyle instance = NativeADStyle._internal();

  /// Factory constructor to provide access to the singleton [NativeADStyle].
  factory NativeADStyle() {
    return instance;
  }

  /// Private constructor for [NativeADStyle] singleton.
  NativeADStyle._internal();

  /// Returns the factory ID for medium native ads if native layout is enabled.
  String? get mediumNativeFactoryId =>
      !isFlutterLayout ? factoryIdMediumNative : null;

  /// Returns the factory ID for small native ads if native layout is enabled.
  String? get smallNativeFactoryId =>
      !isFlutterLayout ? factoryIdSmallNative : null;

  /// The decoration for the native ad container in Light Mode.
  BoxDecoration get lightDecoration =>
      config.nativeADLayout?.lightDecoration ?? BoxDecoration();

  /// Legacy alias getter for [lightDecoration] for backward compatibility.
  BoxDecoration get decoration => lightDecoration;

  /// The decoration for the native ad container in Dark Mode.
  BoxDecoration? get darkDecoration =>
      config.nativeADLayout?.darkDecoration;

  /// The padding for the native ad container.
  EdgeInsets get padding => config.nativeADLayout?.padding ?? const EdgeInsets.all(5);

  /// The margin for the native ad container.
  EdgeInsets get margin => config.nativeADLayout?.margin ?? const EdgeInsets.all(5);

  /// Dynamically resolves whether Dark Mode is currently active based on AdThemeMode and BuildContext.
  bool isDarkMode({BuildContext? context}) {
    final mode = config.themeMode;
    if (mode == AdThemeMode.dark) return true;
    if (mode == AdThemeMode.light) return false;
    if (context != null) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark ||
          Theme.of(context).brightness == Brightness.dark;
    }
    return false;
  }

  /// Dynamically resolves the active CustomNativeADStyle based on theme mode.
  CustomNativeADStyle getCustomStyle({BuildContext? context}) {
    final isDark = isDarkMode(context: context);
    if (isDark && config.nativeADLayout?.darkCustomNativeADStyle != null) {
      return config.nativeADLayout!.darkCustomNativeADStyle!;
    }
    return config.nativeADLayout?.customNativeADStyle ?? CustomNativeADStyle();
  }

  /// Dynamically resolves the active FlutterNativeADStyle based on theme mode.
  FlutterNativeADStyle getFlutterStyle({BuildContext? context}) {
    final isDark = isDarkMode(context: context);
    if (isDark && config.nativeADLayout?.darkFlutterNativeADStyle != null) {
      return config.nativeADLayout!.darkFlutterNativeADStyle!;
    }
    return config.nativeADLayout?.flutterNativeADStyle ?? FlutterNativeADStyle();
  }

  /// Custom styling settings for native ads (defaults to current active style).
  CustomNativeADStyle get customStyle => getCustomStyle();

  /// Flutter-based template styling settings for native ads.
  FlutterNativeADStyle get flutterStyle => getFlutterStyle();

  /// Returns the template style for medium native ads if using Flutter layout.
  NativeTemplateStyle? getNativeMediumTemplateStyle({BuildContext? context}) {
    if (!isFlutterLayout) return null;
    final fStyle = getFlutterStyle(context: context);
    return NativeTemplateStyle(
      templateType: TemplateType.medium,
      mainBackgroundColor: fStyle.mainBackgroundColor,
      cornerRadius: fStyle.cornerRadius,
      callToActionTextStyle: fStyle.callToActionTextStyle,
      primaryTextStyle: fStyle.primaryTextStyle,
      secondaryTextStyle: fStyle.secondaryTextStyle,
      tertiaryTextStyle: fStyle.tertiaryTextStyle,
    );
  }

  /// Returns the template style for small native ads if using Flutter layout.
  NativeTemplateStyle? getNativeSmallTemplateStyle({BuildContext? context}) {
    if (!isFlutterLayout) return null;
    final fStyle = getFlutterStyle(context: context);
    return NativeTemplateStyle(
      templateType: TemplateType.small,
      mainBackgroundColor: fStyle.mainBackgroundColor,
      cornerRadius: fStyle.cornerRadius,
      callToActionTextStyle: fStyle.callToActionTextStyle,
      primaryTextStyle: fStyle.primaryTextStyle,
      secondaryTextStyle: fStyle.secondaryTextStyle,
      tertiaryTextStyle: fStyle.tertiaryTextStyle,
    );
  }

  /// Legacy getter for medium template style.
  NativeTemplateStyle? get nativeMediumTemplateStyle => getNativeMediumTemplateStyle();

  /// Legacy getter for small template style.
  NativeTemplateStyle? get nativeSmallTemplateStyle => getNativeSmallTemplateStyle();

  /// Returns constraints for medium native ads based on the layout type.
  BoxConstraints get mediumConstraintsSize => isFlutterLayout
      ? flutterStyle?.mediumBoxConstrain ??
          BoxConstraints(
            minWidth: 320,
            minHeight: 280,
            maxWidth: 400,
            maxHeight: 365,
          )
      : customStyle?.mediumBoxConstrain ??
          BoxConstraints(
            minWidth: 320,
            minHeight: 210,
            maxWidth: 400,
            maxHeight: 265,
          );

  /// Returns constraints for small native ads based on the layout type.
  BoxConstraints get smallConstraintsSize => isFlutterLayout
      ? flutterStyle?.smallBoxConstrain ??
          BoxConstraints(
            minWidth: 320,
            minHeight: 88,
            maxWidth: 400,
            maxHeight: 120,
          )
      : customStyle?.smallBoxConstrain ??
          BoxConstraints(
            minWidth: 320,
            minHeight: 57,
            maxWidth: 400,
            maxHeight: 135,
          );
}
