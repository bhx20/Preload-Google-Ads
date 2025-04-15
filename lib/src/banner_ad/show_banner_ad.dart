import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../preload_ad.dart';

class ShowBannerAd extends StatefulWidget {
  const ShowBannerAd({super.key});

  @override
  State<ShowBannerAd> createState() => _ShowBannerAdState();
}

class _ShowBannerAdState extends State<ShowBannerAd> {
  late BannerAd banner;

  @override
  void initState() {
    if (LoadBannerAd.instance.bannerAdObject.isNotEmpty &&
        LoadSmallNative.instance.loading == false) {
      banner = LoadBannerAd.instance.bannerAdObject.removeAt(0);
      LoadBannerAd.instance.loadAd();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadBannerAd.instance.bannerAdObject.isNotEmpty
        ? adView()
        : const SizedBox();
  }

  Widget adView() {
    try {
      return SizedBox(height: 70, child: AdWidget(ad: banner));
    } catch (e) {
      return const SizedBox();
    }
  }
}
