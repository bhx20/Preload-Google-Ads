import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../preload_google_ads.dart';

class LoadBannerAd {
  static final LoadBannerAd instance = LoadBannerAd._internal();

  factory LoadBannerAd() {
    return instance;
  }

  LoadBannerAd._internal();

  List<BannerAd> bannerAdObject = [];
  int reloadAd = 1;
  bool loading = false;

  Future<void> loadAd() async {
    BannerAd? bannerAd;

    if (bannerAdObject.length <= 2) {
      try {
        loading = true;
        final view = PlatformDispatcher.instance.implicitView!;
        final double logicalScreenWidth =
            view.physicalSize.width / view.devicePixelRatio;

        final AnchoredAdaptiveBannerAdSize? size =
            await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
              logicalScreenWidth.toInt(),
            );

        if (size == null) {
          return;
        }
        bannerAd = BannerAd(
          adUnitId:
              PreloadGoogleAds.instance.initialData.bannerId ??
              AdTestIds.banner,
          size: size,
          request: const AdRequest(),
          listener: BannerAdListener(
            onAdLoaded: (Ad ad) {
              AppLogger.log('$ad loaded.');
              if (bannerAd != null) {
                bannerAdObject.add(bannerAd);
              }
              if (bannerAdObject.length < 2) {
                loadAd();
              }
              AdStats.instance.bannerLoad.value++;
              loading = false;
            },
            onAdImpression: (add) {
              AdStats.instance.bannerImp.value++;
            },

            onAdFailedToLoad: (Ad ad, LoadAdError error) {
              loading = false;
              AdStats.instance.bannerFailed.value++;
              ad.dispose();
              if (reloadAd == 1) {
                reloadAd--;
                loadAd();
                AppLogger.error("Failed Banner AD");
                AppLogger.error(error.toString());
              } else {
                reloadAd = 1;
              }
            },
          ),
        );
        await bannerAd.load();
      } catch (error) {
        AppLogger.error("catch error");
        AppLogger.error(error.toString());
      }
    }
  }
}
