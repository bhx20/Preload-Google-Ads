import 'package:flutter/material.dart';

import '../../../preload_google_ads.dart';

class GoogleAddRepoImpl extends GoogleAddRepo {
  @override
  Widget googleBannerAdd() {
    return const GoogleBannerAdvertise();
  }

  @override
  Future<void> loadLargeNative() {
    return LoadLargeNative.instance.loadAd();
  }

  @override
  Future<void> loadSmallNative() {
    return LoadSmallNative.instance.loadAd();
  }

  @override
  Future<void> googleOpenAppAdd() {
    return GoogleOpenAppAdvertise.instance.getOpenAppAdvertise();
  }

  @override
  void loadGoogleInterstitialAdd() {
    return GoogleInterstitialAdvertise.instance.load();
  }

  @override
  void showGoogleInterstitialAdd(Function() callBack) {
    return GoogleInterstitialAdvertise.instance.showAndNavigate(
      callBack: callBack,
    );
  }

  @override
  Widget showNative({bool isSmall = false}) {
    return ShowNative(isSmall: isSmall);
  }

  @override
  Future<void> showOpenAppOnSplash({
    required Function() onAdStartAdImpression,
  }) {
    return GoogleAppOpenOnSplash.instance.loadAndShowSplashAd(
      onAdStartAdImpression: onAdStartAdImpression,
    );
  }

  @override
  Widget showAdCounter(bool showCounter) {
    return AdCounterWidget(showCounter: ValueNotifier(showCounter));
  }
}
