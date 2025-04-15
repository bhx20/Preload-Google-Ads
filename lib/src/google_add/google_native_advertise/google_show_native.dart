import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../preload_google_ads.dart';

var nativeCounter = 0;

class ShowNative extends StatelessWidget {
  final bool isSmall;
  const ShowNative({super.key, required this.isSmall});

  @override
  Widget build(BuildContext context) {
    if (nativeCounter >= PreloadAds.instance.initialData.nativeCounter) {
      nativeCounter = 0;
      if (PreloadAds.instance.initialData.showNative == true &&
          PreloadAds.instance.initialData.showAd == true) {
        return isSmall ? const GoogleNativeSmall() : const GoogleNativeLarge();
      } else {
        return const SizedBox.shrink();
      }
    } else {
      nativeCounter++;
      return const SizedBox.shrink();
    }
  }
}

//==============================================================================
//   ** Large Native ***
//==============================================================================

class GoogleNativeLarge extends StatefulWidget {
  const GoogleNativeLarge({super.key});

  @override
  State<GoogleNativeLarge> createState() => _GoogleNativeLargeState();
}

class _GoogleNativeLargeState extends State<GoogleNativeLarge> {
  late NativeAd native;

  @override
  void initState() {
    if (LoadLargeNative.instance.nativeObjectLarge.isNotEmpty &&
        LoadLargeNative.instance.loading == false) {
      native = LoadLargeNative.instance.nativeObjectLarge.removeAt(0);
      LoadLargeNative.instance.loadAd();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      child:
          LoadLargeNative.instance.nativeObjectLarge.isNotEmpty
              ? adView()
              : const SizedBox(),
    );
  }

  Widget adView() {
    try {
      return SizedBox(height: 290, child: AdWidget(ad: native));
    } catch (e) {
      return const SizedBox();
    }
  }
}

//==============================================================================
//   ** Small Native ***
//==============================================================================

class GoogleNativeSmall extends StatefulWidget {
  const GoogleNativeSmall({super.key});

  @override
  State<GoogleNativeSmall> createState() => _GoogleNativeSmallState();
}

class _GoogleNativeSmallState extends State<GoogleNativeSmall> {
  late NativeAd native;

  @override
  void initState() {
    if (LoadSmallNative.instance.nativeObjectSmall.isNotEmpty &&
        LoadSmallNative.instance.loading == false) {
      native = LoadSmallNative.instance.nativeObjectSmall.removeAt(0);
      LoadSmallNative.instance.loadAd();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      child:
          LoadSmallNative.instance.nativeObjectSmall.isNotEmpty
              ? adView()
              : const SizedBox(),
    );
  }

  Widget adView() {
    try {
      return SizedBox(height: 160, child: AdWidget(ad: native));
    } catch (e) {
      return const SizedBox();
    }
  }
}
