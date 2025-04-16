import 'package:flutter/material.dart';

import '../../preload_ad.dart';

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

  showOpenAppOnSplash({required Function() onAdStartAdImpression});

  void loadInterAd();

  void showInterAd({required Function() callBack});

  void loadRewardedAd();

  void showRewardedAd({
    required Function() callBack,
    required Function() onReward,
  });

  Widget showAdCounter(bool showCounter);
}
