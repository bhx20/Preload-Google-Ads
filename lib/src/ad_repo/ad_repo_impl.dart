import 'package:flutter/material.dart';

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
  void showInterAd(Function() callBack) {
    return InterAd.instance.showAndNavigate(callBack: callBack);
  }

  @override
  Widget showNative({bool isSmall = false}) {
    return ShowNative(isSmall: isSmall);
  }

  @override
  showOpenAppOnSplash({required Function() onAdStartAdImpression}) {
    return GoogleAppOpenOnSplash.instance.loadAndShowSplashAd(
      onAdStartAdImpression: onAdStartAdImpression,
    );
  }
}
