/// **Preload Google Ads** — A high-performance Flutter plugin for background preloading of AdMob ads.
///
/// Deliver a zero-latency ad experience by fetching App Open, Interstitial, Rewarded, Rewarded Interstitial,
/// Native (Small/Medium), and Banner ads in the background before they are shown to users.
library preload_google_ads;

export 'package:flutter/foundation.dart';
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:google_mobile_ads/google_mobile_ads.dart';

export 'src/ad_commons/constants.dart'
    show
        AdLayout,
        NativeADType,
        CollapsibleBannerPosition,
        AdTestIds,
        factoryIdMediumNative,
        factoryIdSmallNative;

export 'src/ad_commons/preload_data_model.dart'
    show
        AdConfigData,
        AdCounter,
        AdFlag,
        AdIDS,
        AdThemeMode,
        BannerADLayout,
        CustomNativeADStyle,
        FlutterNativeADStyle,
        NativeADLayout,
        NativeTemplateFontStyle,
        NativeTemplateTextStyle;

export 'src/ad_counter/ad_counter.dart' show AdStats, AdCounterWidget;
export 'src/ad_initial.dart';
export 'src/native_ad/native_ad_style.dart';
