import 'package:flutter/material.dart';

import '../../preload_ad.dart';

class PlugAd {
  static AdRepoImpl getInstance() {
    return AdRepoImpl();
  }
}

abstract class AdRepo {
  void loadMediumNative();

  void loadSmallNative();

  Widget showNative({bool isSmall = false});

  Widget showBannerAd();

  Widget showAdCounter(bool showCounter);

  Future<void> loadAppOpenAd();

  showOpenAppOnSplash({required Function() onAdStartAdImpression});

  void loadInterAd();

  void showInterAd(Function() callBack);
}
