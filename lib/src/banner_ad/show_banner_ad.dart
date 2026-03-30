import '../ad_internal.dart';

/// A StatefulWidget to display a banner ad.
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

    /// If banner ads are available, take one.
    banner = LoadBannerAd.instance.takeAd();
    
    /// Trigger loadAd to ensure cache is replenished.
    LoadBannerAd.instance.loadAd();
  }

  @override
  void dispose() {
    banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// If there is an initialized banner, display it.
    if (banner != null) {
      return adView();
    }

    /// If no ad is ready, listen for the next available one.
    return ValueListenableBuilder<List<BannerAd>>(
      valueListenable: LoadBannerAd.instance.bannerAds,
      builder: (context, ads, _) {
        if (banner == null && ads.isNotEmpty) {
          // An ad is now available, grab it!
          // We use microtask to avoid calling setState during build.
          Future.microtask(() {
            if (mounted && banner == null) {
              setState(() {
                banner = LoadBannerAd.instance.takeAd();
              });
            }
          });
        }

        return banner != null ? adView() : const SizedBox.shrink();
      },
    );
  }

  /// Builds the widget to display the banner ad.
  Widget adView() {
    final ad = banner;
    if (ad == null) return const SizedBox.shrink();
    
    try {
      return Container(
        alignment: Alignment.center,
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      );
    } catch (e) {
      AppLogger.error("Exception in ShowBannerAd.adView: $e");
      return const SizedBox.shrink();
    }
  }
}
