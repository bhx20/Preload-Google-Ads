import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../preload_google_ads.dart';

var nativeCounter = 0;

class ShowNative extends StatelessWidget {
  final bool isSmall;
  const ShowNative({super.key, required this.isSmall});

  @override
  Widget build(BuildContext context) {
    final dataCounter =
        PreloadGoogleAds.instance.initialData.nativeCounter ?? 0;
    if (nativeCounter >= dataCounter) {
      nativeCounter = 0;
      if (PreloadGoogleAds.instance.initialData.showNative == true &&
          PreloadGoogleAds.instance.initialData.showAd == true) {
        return isSmall ? const NativeSmall() : const MediumNative();
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

class MediumNative extends StatefulWidget {
  const MediumNative({super.key});

  @override
  State<MediumNative> createState() => _MediumNativeState();
}

class _MediumNativeState extends State<MediumNative> {
  late NativeAd native;

  @override
  void initState() {
    if (LoadMediumNative.instance.nativeObjectLarge.isNotEmpty &&
        LoadMediumNative.instance.loading == false) {
      native = LoadMediumNative.instance.nativeObjectLarge.removeAt(0);
      LoadMediumNative.instance.loadAd();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadMediumNative.instance.nativeObjectLarge.isNotEmpty
        ? adView()
        : const SizedBox();
  }

  Widget adView() {
    try {
      return SizedBox(height: 255, child: Center(child: AdWidget(ad: native)));
    } catch (e) {
      return const SizedBox();
    }
  }
}

//==============================================================================
//   ** Small Native ***
//==============================================================================

class NativeSmall extends StatefulWidget {
  const NativeSmall({super.key});

  @override
  State<NativeSmall> createState() => _NativeSmallState();
}

class _NativeSmallState extends State<NativeSmall> {
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
    return LoadSmallNative.instance.nativeObjectSmall.isNotEmpty
        ? adView()
        : const SizedBox();
  }

  Widget adView() {
    try {
      return SizedBox(height: 125, child: AdWidget(ad: native));
    } catch (e) {
      return const SizedBox();
    }
  }
}
