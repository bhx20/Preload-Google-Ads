import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../preload_google_ads.dart';

class PlugAd {
  static AdRepoImpl getInstance() {
    return AdRepoImpl();
  }
}

abstract class AdRepo {
  Future<void> loadMediumNative();

  Future<void> loadSmallNative();

  Widget showNative({bool isSmall = false});

  Future<void> loadBannerAd();

  Widget showBannerAd();

  Future<void> loadAppOpenAd();

  void showOpenAppAd();

  showOpenAppOnSplash({
    required Function({AppOpenAd? ad, AdError? error}) callBack,
  });

  void loadInterAd();

  void showInterAd({
    required Function({InterstitialAd? ad, AdError? error}) callBack,
  });

  void loadRewardedAd();

  void showRewardedAd({
    required Function({RewardedAd? ad, AdError? error}) callBack,
    required Function(AdWithoutView ad, RewardItem reward) onReward,
  });

  Widget showAdCounter(bool showCounter);
}
