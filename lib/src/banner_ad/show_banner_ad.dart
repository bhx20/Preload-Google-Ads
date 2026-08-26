import '../ad_internal.dart';

/// A StatefulWidget specifically for displaying standard anchored banner ads.
class ShowBannerAd extends StatefulWidget {
  /// Constructor for [ShowBannerAd].
  const ShowBannerAd({super.key});

  @override
  State<ShowBannerAd> createState() => _ShowBannerAdState();
}

class _ShowBannerAdState extends State<ShowBannerAd> {
  /// The banner ad to be displayed.
  BannerAd? banner;

  @override
  void initState() {
    super.initState();
    if (LoadBannerAd.instance.bannerAdObject.isNotEmpty) {
      banner = LoadBannerAd.instance.bannerAdObject.removeAt(0);
    } else {
      _loadStandardBanner();
    }
  }

  Future<void> _loadStandardBanner() async {
    try {
      final view = PlatformDispatcher.instance.implicitView;
      if (view == null) return;
      final double logicalScreenWidth = view.physicalSize.width / view.devicePixelRatio;
      if (logicalScreenWidth <= 0) return;

      final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(logicalScreenWidth.toInt());
      if (size == null) return;

      final stdBanner = BannerAd(
        adUnitId: unitIDBanner,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            if (mounted) {
              setState(() {
                banner = ad as BannerAd;
              });
            }
            AdStats.instance.bannerLoad.value++;
          },
          onAdImpression: (ad) => AdStats.instance.bannerImp.value++,
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            AdStats.instance.bannerFailed.value++;
            ad.dispose();
          },
        ),
      );
      await stdBanner.load();
    } catch (e) {
      AppLogger.error("Failed to load standard banner: $e");
    }
  }

  @override
  void dispose() {
    banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return banner != null ? adView() : const SizedBox.shrink();
  }

  /// Builds the widget to display the banner ad.
  Widget adView() {
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
        alignment: Alignment.center,
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
