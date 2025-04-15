import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../preload_google_ads.dart';
import '../preload_ad.dart';

class GoogleBannerAdvertise extends StatefulWidget {
  const GoogleBannerAdvertise({super.key});

  @override
  _GoogleBannerAdvertiseState createState() => _GoogleBannerAdvertiseState();
}

class _GoogleBannerAdvertiseState extends State<GoogleBannerAdvertise> {
  BannerAd? _bannerAd;
  bool _adLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd != null &&
        _bannerAd!.adUnitId != PreloadAds.instance.initialData.bannerId) {
      _bannerAd!.dispose();
    }
    //loadAd();
  }

  Future<void> loadAd() async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
          MediaQuery.of(context).size.width.truncate(),
        );

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: PreloadAds.instance.initialData.bannerId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$ad loaded: ${ad.responseInfo}');
          setState(() {
            // When the ad is loaded, get the ad size and use it to set
            // the height of the ad container.
            _bannerAd = ad as BannerAd;
            _adLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Anchored adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    return _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (PreloadAds.instance.initialData.showBanner == true &&
        PreloadAds.instance.initialData.showAd == true) {
      if (_adLoaded) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 12,
          width: MediaQuery.of(context).size.width,
          child: AdWidget(ad: _bannerAd!),
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}
