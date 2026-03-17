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

    /// If banner ads are available, load one. Always call loadAd to ensure 
    /// that if the initial pre-load failed (e.g. race condition), it tries again.
    if (LoadBannerAd.instance.bannerAdObject.isNotEmpty) {
      banner = LoadBannerAd.instance.bannerAdObject.removeAt(0);
    }
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
    return banner != null ? adView() : const SizedBox.shrink();
  }

  /// Builds the widget to display the banner ad.
  Widget adView() {
    try {
      return SizedBox(height: 70, child: AdWidget(ad: banner!));
    } catch (e) {
      return const SizedBox.shrink();
    }
  }
}
