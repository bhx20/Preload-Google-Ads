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

  /// The decoration for the native ad container.
  BoxDecoration get decoration =>
      config.nativeADLayout?.decoration ?? BoxDecoration();

  /// The padding for the native ad container.
  EdgeInsets get padding => config.nativeADLayout?.padding ?? const EdgeInsets.all(5);

  /// The margin for the native ad container.
  EdgeInsets get margin => config.nativeADLayout?.margin ?? const EdgeInsets.all(5);

  /// Custom styling settings for native ads.
  CustomNativeADStyle? get customStyle => config.nativeADLayout?.customNativeADStyle;

  /// Flutter-based template styling settings for native ads.
  FlutterNativeADStyle? get flutterStyle =>
      config.nativeADLayout?.flutterNativeADStyle;

  /// Returns the template style for medium native ads if using Flutter layout.
  NativeTemplateStyle? get nativeMediumTemplateStyle => isFlutterLayout
      ? NativeTemplateStyle(
          templateType: TemplateType.medium,
          mainBackgroundColor: flutterStyle?.mainBackgroundColor,
          cornerRadius: flutterStyle?.cornerRadius,
          callToActionTextStyle: flutterStyle?.callToActionTextStyle,
          primaryTextStyle: flutterStyle?.primaryTextStyle,
          secondaryTextStyle: flutterStyle?.secondaryTextStyle,
          tertiaryTextStyle: flutterStyle?.tertiaryTextStyle,
        )
      : null;

  /// Returns the template style for small native ads if using Flutter layout.
  NativeTemplateStyle? get nativeSmallTemplateStyle => isFlutterLayout
      ? NativeTemplateStyle(
          templateType: TemplateType.small,
          mainBackgroundColor: flutterStyle?.mainBackgroundColor,
          cornerRadius: flutterStyle?.cornerRadius,
          callToActionTextStyle: flutterStyle?.callToActionTextStyle,
          primaryTextStyle: flutterStyle?.primaryTextStyle,
          secondaryTextStyle: flutterStyle?.secondaryTextStyle,
          tertiaryTextStyle: flutterStyle?.tertiaryTextStyle,
        )
      : null;

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
