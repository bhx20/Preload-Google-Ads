import 'package:preload_google_ads/preload_google_ads.dart';
import '../widgets/ad_builder_preview.dart';

/// The main dashboard that displays various ad formats and customization options.
class MainDashboard extends StatefulWidget {
  /// Creates a [MainDashboard].
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  /// The currently displayed ad widget.
  Widget? currentAd;

  /// A label describing the current ad format.
  String currentAdTypeLabel = "No Ad Selected";

  /// Whether a style refresh is in progress.
  bool isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ad Dashboard'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFormatGrid(theme),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Live Preview: $currentAdTypeLabel",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (currentAd != null)
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => setState(() {
                              currentAd = null;
                              currentAdTypeLabel = "No Ad Selected";
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.1),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isRefreshing
                              ? const Center(child: CircularProgressIndicator())
                              : (currentAd != null
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      child: Center(child: currentAd),
                                    )
                                  : _buildEmptyPreview(theme)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PreloadGoogleAds.instance.showAdCounter(showCounter: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatGrid(ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.5,
      children: [
        _formatIcon(
          Icons.fullscreen,
          "Inter",
          Colors.blue,
          () => PreloadGoogleAds.instance.showInterstitialAd(
            callBack: (ad, error) =>
                _handleAdCallback("Interstitial", ad, error),
          ),
        ),
        _formatIcon(
          Icons.stars,
          "Reward",
          Colors.orange,
          () => PreloadGoogleAds.instance.showRewardedAd(
            callBack: (ad, error) => _handleAdCallback("Rewarded", ad, error),
            onReward: (a, r) =>
                _showSnackBar("Success! Reward: ${r.amount} ${r.type}"),
          ),
        ),
        _formatIcon(
          Icons.launch,
          "Open",
          Colors.purple,
          () => PreloadGoogleAds.instance.showOpenApp(),
        ),
        _formatIcon(
          Icons.view_stream,
          "Banner",
          Colors.green,
          () => _setAd(PreloadGoogleAds.instance.showBannerAd(), "Banner"),
        ),
        _formatIcon(
          Icons.auto_awesome,
          "Builder",
          const Color(0xFF10B981),
          () => _setAd(
            AdBuilderPreview.buildCustomNativeAdView(context),
            "Builder Ad",
          ),
        ),
      ],
    );
  }

  Widget _formatIcon(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPreview(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.ads_click,
          size: 40,
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 8),
        Text(
          "Select Format",
          style: TextStyle(color: theme.colorScheme.outline),
        ),
      ],
    );
  }

  void _setAd(Widget ad, String label) {
    setState(() {
      currentAd = ad;
      currentAdTypeLabel = label;
    });
  }


  void _handleAdCallback(String type, dynamic ad, AdError? error) {
    if (error != null) {
      _showSnackBar(error.message);
    } else {
      _showSnackBar("$type Ad opened successfully");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
