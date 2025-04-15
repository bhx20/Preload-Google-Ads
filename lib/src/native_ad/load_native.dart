import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../preload_ad.dart';

//==============================================================================
//   ** Large Native ***
//==============================================================================

class LoadMediumNative {
  static final LoadMediumNative instance = LoadMediumNative._internal();

  factory LoadMediumNative() {
    return instance;
  }

  LoadMediumNative._internal();

  List<NativeAd> nativeObjectLarge = [];
  int reloadAd = 1;
  bool loading = false;

  Future<void> loadAd() async {
    NativeAd? nativeAd;

    if (nativeObjectLarge.length <= 2) {
      try {
        loading = true;
        nativeAd = NativeAd(
          factoryId: "listTileMedium",
          adUnitId: PreloadAds.instance.initialData.nativeId,
          listener: NativeAdListener(
            onAdLoaded: (ad) async {
              AppLogger.log('$NativeAd loaded.');
              if (nativeAd != null) {
                nativeObjectLarge.add(nativeAd);
              }
              if (nativeObjectLarge.length < 2) {
                loadAd();
              }
              AdStats.instance.nativeLoadM.value++;
              loading = false;
            },
            onAdImpression: (add) {
              AdStats.instance.nativeImpM.value++;
            },
            onAdFailedToLoad: (ad, error) {
              loading = false;
              AdStats.instance.nativeFailedM.value++;
              ad.dispose();
              if (reloadAd == 1) {
                reloadAd--;
                loadAd();
                AppLogger.error("failed ad large");
                AppLogger.error(error.toString());
              } else {
                reloadAd = 1;
              }
            },
          ),
          request: const AdRequest(),
        );
        await nativeAd.load();
      } catch (error) {
        AppLogger.error("catch error");
        AppLogger.error(error.toString());
      }
    }
  }
}

//==============================================================================
//   ** Small Native ***
//==============================================================================

class LoadSmallNative {
  static final LoadSmallNative instance = LoadSmallNative._internal();

  factory LoadSmallNative() {
    return instance;
  }

  LoadSmallNative._internal();

  List<NativeAd> nativeObjectSmall = [];
  int reloadAd = 1;
  bool loading = false;

  Future<void> loadAd() async {
    NativeAd? nativeAd;
    if (nativeObjectSmall.length <= 2) {
      loading = true;
      try {
        nativeAd = NativeAd(
          factoryId: "listTile",
          adUnitId: PreloadAds.instance.initialData.nativeId,
          listener: NativeAdListener(
            onAdLoaded: (ad) async {
              if (nativeAd != null) {
                nativeObjectSmall.add(nativeAd);
              }
              if (nativeObjectSmall.length < 2) {
                await loadAd();
              }
              AdStats.instance.nativeLoadS.value++;
              loading = false;
            },
            onAdImpression: (ad) {
              AdStats.instance.nativeImpS.value++;
            },
            onAdFailedToLoad: (ad, error) {
              loading = false;
              AdStats.instance.nativeFailedS.value++;
              ad.dispose();
              if (reloadAd == 1) {
                reloadAd--;
                loadAd();
              } else {
                reloadAd = 1;
              }
            },
          ),
          request: const AdRequest(),
        );

        await nativeAd.load();
      } catch (error) {
        AppLogger.error("catch error");
        AppLogger.error(error.toString());
      }
    }
  }
}
