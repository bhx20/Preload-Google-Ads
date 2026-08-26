import '../ad_internal.dart';

/// A StatefulWidget specifically for displaying collapsible banner ads (top or bottom).
class ShowCollapsibleBannerAd extends StatefulWidget {
  /// Collapsible position: [CollapsibleBannerPosition.bottom] or [CollapsibleBannerPosition.top]. Defaults to [CollapsibleBannerPosition.bottom].
  final CollapsibleBannerPosition collapsiblePosition;

  /// Optional key override.
  final Key? key;

  const ShowCollapsibleBannerAd({
    this.key,
    this.collapsiblePosition = CollapsibleBannerPosition.bottom,
  }) : super(key: key);

  @override
  State<ShowCollapsibleBannerAd> createState() => _ShowCollapsibleBannerAdState();
}

class _ShowCollapsibleBannerAdState extends State<ShowCollapsibleBannerAd> {
  BannerAd? banner;

  @override
  void initState() {
    super.initState();
    _loadCollapsibleBanner();
  }

  Future<void> _loadCollapsibleBanner() async {
    try {
      final view = PlatformDispatcher.instance.implicitView;
      if (view == null) return;
      final double logicalScreenWidth = view.physicalSize.width / view.devicePixelRatio;
      if (logicalScreenWidth <= 0) return;

      final AnchoredAdaptiveBannerAdSize? size =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        logicalScreenWidth.toInt(),
      );

      if (size == null) return;

      final positionString = widget.collapsiblePosition.name;

      final AdRequest request = AdRequest(
        extras: <String, String>{
          'collapsible': positionString,
          'collapsible_request_id': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );

      final colBanner = BannerAd(
        adUnitId: unitIDBanner,
        size: size,
        request: request,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            if (mounted) {
              setState(() {
                banner = ad as BannerAd;
              });
            }
            AdStats.instance.bannerLoad.value++;
          },
          onAdImpression: (ad) {
            AdStats.instance.bannerImp.value++;
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            AdStats.instance.bannerFailed.value++;
            ad.dispose();
          },
        ),
      );
      await colBanner.load();
    } catch (e) {
      AppLogger.error("Failed to load collapsible banner: $e");
    }
  }

  @override
  void dispose() {
    banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (banner == null) return const SizedBox.shrink();

    try {
      final double nativeHeight = banner!.size.height.toDouble();
      final double targetHeight = nativeHeight > 0 ? nativeHeight : 50.0;
      final isDark = NativeADStyle.instance.isDarkMode(context: context);

      final bannerLayout = config.bannerADLayout;
      final decoration = (isDark && bannerLayout?.darkDecoration != null)
          ? bannerLayout?.darkDecoration
          : bannerLayout?.lightDecoration;

      return Container(
        width: double.infinity,
        decoration: decoration,
        margin: bannerLayout?.margin,
        padding: bannerLayout?.padding,
        alignment: widget.collapsiblePosition == CollapsibleBannerPosition.top
            ? Alignment.topCenter
            : Alignment.bottomCenter,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: banner!.size.width > 0 ? banner!.size.width.toDouble() : double.infinity,
            height: targetHeight,
            child: AdWidget(ad: banner!),
          ),
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }
}
