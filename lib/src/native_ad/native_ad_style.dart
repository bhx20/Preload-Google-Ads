import '../../preload_google_ads.dart';

class NativeADStyle {
  static final NativeADStyle instance = NativeADStyle._internal();

  factory NativeADStyle() {
    return instance;
  }

  NativeADStyle._internal();

  String? get mediumNativeFactoryId =>
      !isFlutterLayout ? factoryIdMediumNative : null;

  String? get smallNativeFactoryId =>
      !isFlutterLayout ? factoryIdSmallNative : null;

  BoxDecoration decoration =
      config.nativeADLayout?.decoration ?? BoxDecoration();

  EdgeInsets padding = config.nativeADLayout?.padding ?? EdgeInsets.all(5);

  EdgeInsets margin = config.nativeADLayout?.margin ?? EdgeInsets.all(5);

  CustomNativeADStyle? customStyle = config.nativeADLayout?.customNativeADStyle;
  FlutterNativeADStyle? flutterStyle =
      config.nativeADLayout?.flutterNativeADStyle;

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
