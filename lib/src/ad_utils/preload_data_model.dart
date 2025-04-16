import 'package:flutter/material.dart';

class AdConfigData {
  final String? appOpenId;
  final String? bannerId;
  final String? nativeId;
  final String? interstitialId;
  final String? rewardedId;
  final int? interstitialCounter;
  final int? rewardedCounter;
  final int? nativeCounter;
  final bool? showAd;
  final bool? showBanner;
  final bool? showInterstitial;
  final bool? showNative;
  final bool? showSplashAd;
  final bool? showOpenApp;
  final bool? showRewarded;

  AdConfigData({
    this.appOpenId,
    this.bannerId,
    this.interstitialId,
    this.interstitialCounter,
    this.rewardedCounter,
    this.nativeCounter,
    this.nativeId,
    this.showAd,
    this.showBanner,
    this.showInterstitial,
    this.showNative,
    this.showOpenApp,
    this.rewardedId,
    this.showSplashAd,
    this.showRewarded,
  });
}

class AdStyle {
  Color title;
  Color description;
  Color tagBackground;
  Color tagForeground;
  Color buttonBackground;
  Color buttonForeground;
  int buttonRadius;
  int tagRadius;
  List<Color> buttonGradients;

  AdStyle({
    this.title = const Color(0xFF000000),
    this.description = const Color(0xFF808080),
    this.tagBackground = const Color(0xFFF19938),
    this.tagForeground = const Color(0xFFFFFFFF),
    this.buttonBackground = const Color(0xFF2196F3),
    this.buttonForeground = const Color(0xFFFFFFFF),
    this.buttonRadius = 5,
    this.tagRadius = 5,
    List<Color>? buttonGradients,
  }) : buttonGradients = buttonGradients ?? [];
}
