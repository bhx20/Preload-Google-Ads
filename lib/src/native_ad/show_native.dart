import '../ad_internal.dart';

/// A counter to track the number of native ads shown.
var nativeCounter = 0;

/// A widget that determines which type of native ad (small or medium) to show
/// based on the `nativeADType` and the counter logic.
class ShowNative extends StatelessWidget {
  /// The type of native ad to display.
  final NativeADType nativeADType;

  /// Constructor for [ShowNative].
  const ShowNative({super.key, required this.nativeADType});

  @override
  Widget build(BuildContext context) {
    /// If the counter exceeds the native ad display limit, reset it and show the ad if allowed.

    bool isSmall = nativeADType == NativeADType.small;
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

/// A internal helper widget to manage common state for native ad views.
abstract class _NativeAdViewState<T extends StatefulWidget> extends State<T> {
  final BaseNativeAdLoader loader;
  final BoxConstraints constraints;
  NativeAd? _ad;

  _NativeAdViewState({required this.loader, required this.constraints});

  @override
  void initState() {
    super.initState();
    if (loader.ads.isNotEmpty && !loader.isLoading) {
      _ad = loader.ads.removeAt(0);
      loader.loadAd();
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ad == null) return const SizedBox.shrink();

    try {
      return Container(
        decoration: NativeADStyle.instance.decoration,
        constraints: constraints,
        margin: NativeADStyle.instance.margin,
        padding: NativeADStyle.instance.padding,
        child: Center(child: AdWidget(ad: _ad!)),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }
}

/// A widget that displays a medium-sized native ad.
class MediumNative extends StatefulWidget {
  /// Constructor for [MediumNative].
  const MediumNative({super.key});

  @override
  State<MediumNative> createState() => _MediumNativeState();
}

class _MediumNativeState extends _NativeAdViewState<MediumNative> {
  _MediumNativeState()
      : super(
          loader: LoadMediumNative.instance,
          constraints: NativeADStyle.instance.mediumConstraintsSize,
        );
}

/// A widget that displays a small-sized native ad.
class NativeSmall extends StatefulWidget {
  /// Constructor for [NativeSmall].
  const NativeSmall({super.key});

  @override
  State<NativeSmall> createState() => _NativeSmallState();
}

class _NativeSmallState extends _NativeAdViewState<NativeSmall> {
  _NativeSmallState()
      : super(
          loader: LoadSmallNative.instance,
          constraints: NativeADStyle.instance.smallConstraintsSize,
        );
}
