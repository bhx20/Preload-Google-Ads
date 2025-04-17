import '../../preload_google_ads.dart';

/// A counter to track the number of native ads shown.
var nativeCounter = 0;

/// A widget that determines which type of native ad (small or medium) to show
/// based on the `isSmall` flag and the counter logic.
class ShowNative extends StatelessWidget {
  final bool isSmall;

  const ShowNative({super.key, required this.isSmall});

  @override
  Widget build(BuildContext context) {
    /// If the counter exceeds the native ad display limit, reset it and show the ad if allowed.
    if (nativeCounter >= getNativeCounter) {
      nativeCounter = 0;
      if (shouldShowNativeAd) {
        // Show either small or medium native ad based on the `isSmall` flag.
        return isSmall ? const NativeSmall() : const MediumNative();
      } else {
        // If the native ad should not be shown, return an empty space.
        return const SizedBox.shrink();
      }
    } else {
      nativeCounter++;
      // If the counter limit is not reached, return an empty space.
      return const SizedBox.shrink();
    }
  }
}

///==============================================================================
///   ** Large Native ***
///==============================================================================

/// A widget that displays a medium-sized native ad.
class MediumNative extends StatefulWidget {
  const MediumNative({super.key});

  @override
  State<MediumNative> createState() => _MediumNativeState();
}

class _MediumNativeState extends State<MediumNative> {
  late NativeAd native;

  @override
  void initState() {
    super.initState();
    // If there are loaded medium native ads, show one and load a new one.
    if (LoadMediumNative.instance.nativeObjectLarge.isNotEmpty &&
        LoadMediumNative.instance.loading == false) {
      native = LoadMediumNative.instance.nativeObjectLarge.removeAt(0);
      LoadMediumNative.instance.loadAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    // If there is a loaded native ad, show it; otherwise, return an empty space.
    return LoadMediumNative.instance.nativeObjectLarge.isNotEmpty
        ? adView()
        : const SizedBox();
  }

  /// Returns a widget to display the ad.
  Widget adView() {
    try {
      // Show the native ad with a specific height.
      return SizedBox(height: 255, child: Center(child: AdWidget(ad: native)));
    } catch (e) {
      // If there is an error, return an empty space.
      return const SizedBox();
    }
  }
}

///==============================================================================
///   ** Small Native ***
///==============================================================================

/// A widget that displays a small-sized native ad.
class NativeSmall extends StatefulWidget {
  const NativeSmall({super.key});

  @override
  State<NativeSmall> createState() => _NativeSmallState();
}

class _NativeSmallState extends State<NativeSmall> {
  late NativeAd native;

  @override
  void initState() {
    super.initState();
    // If there are loaded small native ads, show one and load a new one.
    if (LoadSmallNative.instance.nativeObjectSmall.isNotEmpty &&
        LoadSmallNative.instance.loading == false) {
      native = LoadSmallNative.instance.nativeObjectSmall.removeAt(0);
      LoadSmallNative.instance.loadAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    // If there is a loaded native ad, show it; otherwise, return an empty space.
    return LoadSmallNative.instance.nativeObjectSmall.isNotEmpty
        ? adView()
        : const SizedBox();
  }

  /// Returns a widget to display the ad.
  Widget adView() {
    try {
      // Show the small native ad with a specific height.
      return SizedBox(height: 125, child: AdWidget(ad: native));
    } catch (e) {
      // If there is an error, return an empty space.
      return const SizedBox();
    }
  }
}
