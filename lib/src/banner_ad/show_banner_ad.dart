import '../ad_internal.dart';

/// A StatefulWidget to display a banner ad (standard or collapsible).
class ShowBannerAd extends StatefulWidget {
  /// Collapsible type: 'bottom' or 'top', or null for standard anchored banner.
  final String? isCollapsible;

  /// Constructor for [ShowBannerAd].
  const ShowBannerAd({super.key, this.isCollapsible});

  @override
  State<ShowBannerAd> createState() => _ShowBannerAdState();
}

class _ShowBannerAdState extends State<ShowBannerAd> {
  /// The banner ad to be displayed.
  BannerAd? banner;

  @override
  void initState() {
    super.initState();

    if (widget.isCollapsible != null) {
      // Collapsible banners require a dedicated on-demand AdRequest with collapsible extras.
      _loadCollapsibleBanner();
    } else {
      if (LoadBannerAd.instance.bannerAdObject.isNotEmpty) {
        banner = LoadBannerAd.instance.bannerAdObject.removeAt(0);
      }
      LoadBannerAd.instance.loadAd();
    }
  }

  Future<void> _loadCollapsibleBanner() async {
    try {
      final view = PlatformDispatcher.instance.implicitView;
      if (view == null) return;
      final double logicalScreenWidth =
          view.physicalSize.width / view.devicePixelRatio;
      if (logicalScreenWidth <= 0) return;

      final AnchoredAdaptiveBannerAdSize? size =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        logicalScreenWidth.toInt(),
      );

      if (size == null) return;

      final AdRequest request = AdRequest(
        extras: <String, String>{
          'collapsible': widget.isCollapsible!,
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
    /// If there is an initialized banner, display it.
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
        alignment: widget.isCollapsible == 'top'
            ? Alignment.topCenter
            : Alignment.bottomCenter,
        child: SizedBox(
          width: banner!.size.width > 0 ? banner!.size.width.toDouble() : double.infinity,
          height: targetHeight,
          child: AdWidget(ad: banner!),
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }
}
