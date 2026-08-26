import 'package:flutter/material.dart';
import 'package:preload_google_ads/preload_google_ads.dart';

class FormatLabScreen extends StatefulWidget {
  const FormatLabScreen({super.key});

  @override
  State<FormatLabScreen> createState() => _FormatLabScreenState();
}

class _FormatLabScreenState extends State<FormatLabScreen> {
  String _activeFormat = "None";
  Widget? _inlineAdWidget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ad Format Test Lab"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fullscreen Formats Section
            Text(
              "FULLSCREEN AD FORMATS",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.secondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _formatCard(
                    context,
                    "Interstitial",
                    Icons.fullscreen_rounded,
                    Colors.indigo,
                    () => _showInterstitial(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _formatCard(
                    context,
                    "Rewarded",
                    Icons.stars_rounded,
                    Colors.amber[800]!,
                    () => _showRewarded(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _formatCard(
                    context,
                    "Reward Inter",
                    Icons.military_tech_rounded,
                    Colors.purple,
                    () => _showRewardedInterstitial(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _formatCard(
                    context,
                    "App Open",
                    Icons.open_in_new_rounded,
                    Colors.pink,
                    () => _showAppOpen(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Inline Banner Formats Section
            Text(
              "INLINE BANNER FORMATS",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.secondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _formatCard(
                    context,
                    "Banner",
                    Icons.view_headline_rounded,
                    Colors.teal,
                    () {
                      setState(() {
                        _activeFormat = "Standard Banner";
                        _inlineAdWidget = PreloadGoogleAds.instance.showBannerAd();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _formatCard(
                    context,
                    "Collapsible (Bottom)",
                    Icons.vertical_align_bottom_rounded,
                    Colors.blue,
                    () {
                      setState(() {
                        _activeFormat = "Collapsible Banner (Bottom)";
                        _inlineAdWidget = PreloadGoogleAds.instance.showBannerAd(
                          isCollapsible: 'bottom',
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Active Inline Stage
            if (_inlineAdWidget != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "PREVIEW: $_activeFormat",
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () => setState(() => _inlineAdWidget = null),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _inlineAdWidget,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _formatCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInterstitial() {
    PreloadGoogleAds.instance.showInterstitialAd(
      callBack: (ad, error) {
        if (error != null) {
          _showSnackBar("Failed to show Interstitial: ${error.message}");
        } else {
          _showSnackBar("Interstitial ad displayed.");
        }
      },
    );
  }

  void _showRewarded() {
    PreloadGoogleAds.instance.showRewardedAd(
      callBack: (ad, error) {
        if (error != null) {
          _showSnackBar("Failed to show Rewarded: ${error.message}");
        }
      },
      onReward: (ad, reward) {
        _showSnackBar("Reward earned: ${reward.amount} ${reward.type}");
      },
    );
  }

  void _showRewardedInterstitial() {
    PreloadGoogleAds.instance.showRewardedInterstitialAd(
      callBack: (ad, error) {
        if (error != null) {
          _showSnackBar("Failed to show Rewarded Interstitial: ${error.message}");
        }
      },
      onReward: (ad, reward) {
        _showSnackBar("Rewarded Interstitial reward earned!");
      },
    );
  }

  void _showAppOpen() {
    PreloadGoogleAds.instance.showOpenApp();
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
