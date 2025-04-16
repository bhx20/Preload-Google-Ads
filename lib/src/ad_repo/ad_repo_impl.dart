import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:preload_google_ads/src/rewarded_ad/rewarded_ad.dart';

import '../../preload_ad.dart';

class AdRepoImpl extends AdRepo {
  @override
  Future<void> loadAppOpenAd() {
    return LifeCycleManager.instance.getOpenAppAdvertise();
  }

  @override
  void loadInterAd() {
    return InterAd.instance.load();
  }

  @override
  Future<void> loadMediumNative() {
    return LoadMediumNative.instance.loadAd();
  }

  @override
  Future<void> loadSmallNative() {
    return LoadSmallNative.instance.loadAd();
  }

  @override
  Widget showAdCounter(bool showCounter) {
    return AdCounterWidget(showCounter: ValueNotifier(showCounter));
  }

  @override
  Widget showBannerAd() {
    return ShowBannerAd();
  }

  @override
  void showInterAd({
    required Function({InterstitialAd? ad, AdError? error}) callBack,
  }) {
    return InterAd.instance.showInter(callBack: callBack);
  }

  @override
  Widget showNative({bool isSmall = false}) {
    return ShowNative(isSmall: isSmall);
  }

  @override
  showOpenAppOnSplash({
    required Function({AppOpenAd? ad, AdError? error}) callBack,
  }) {
    return GoogleAppOpenOnSplash.instance.loadAndShowSplashAd(
      callBack: callBack,
    );
  }

  @override
  void showOpenAppAd() {
    return AppOpenAdManager.instance.showAdIfAvailable();
  }

  @override
  Future<void> loadBannerAd() {
    return LoadBannerAd.instance.loadAd();
  }

  @override
  void loadRewardedAd() {
    return RewardAd.instance.load();
  }

  @override
  void showRewardedAd({
    required Function({RewardedAd? ad, AdError? error}) callBack,
    required Function(AdWithoutView ad, RewardItem reward) onReward,
  }) {
    return RewardAd.instance.showRewarded(
      callBack: callBack,
      onReward: onReward,
    );
  }
}
