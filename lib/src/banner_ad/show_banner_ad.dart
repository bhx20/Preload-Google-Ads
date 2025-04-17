import '../../preload_google_ads.dart';

/// A StatefulWidget to display a banner ad.
class ShowBannerAd extends StatefulWidget {
  const ShowBannerAd({super.key});

  @override
  State<ShowBannerAd> createState() => _ShowBannerAdState();
}

class _ShowBannerAdState extends State<ShowBannerAd> {
  /// The banner ad to be displayed.
  late BannerAd banner;

  @override
  void initState() {
    super.initState();

    /// If banner ads are available and small native ads are not loading,
    /// load a banner ad and remove it from the list of available ads.
    if (LoadBannerAd.instance.bannerAdObject.isNotEmpty &&
        LoadSmallNative.instance.loading == false) {
      banner = LoadBannerAd.instance.bannerAdObject.removeAt(0);
      LoadBannerAd.instance.loadAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    /// If there are available banner ads, display the ad. Otherwise, return an empty widget.
    return LoadBannerAd.instance.bannerAdObject.isNotEmpty
        ? adView()
        : const SizedBox();
  }

  /// Builds the widget to display the banner ad.
  ///
  /// Returns a SizedBox widget containing the AdWidget for displaying the banner ad.
  Widget adView() {
    try {
      return SizedBox(height: 70, child: AdWidget(ad: banner));
    } catch (e) {
      // If there is an error displaying the ad, return an empty SizedBox.
      return const SizedBox();
    }
  }
}
