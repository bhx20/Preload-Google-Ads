import 'package:flutter/material.dart';
import 'package:preload_google_ads/preload_google_ads.dart';
import '../theme/theme_provider.dart';

class BannerAdScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const BannerAdScreen({super.key, required this.themeProvider});

  @override
  State<BannerAdScreen> createState() => _BannerAdScreenState();
}

class _BannerAdScreenState extends State<BannerAdScreen> {
  CollapsibleBannerPosition collapsiblePosition = CollapsibleBannerPosition.bottom;
  int previewKey = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeProvider.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Banner Ad Hub"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFC7D2FE),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.view_stream_rounded, color: isDark ? Colors.indigoAccent : Colors.indigo),
                      const SizedBox(width: 8),
                      const Text(
                        "Banner & Collapsible Banner Ads",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Standard 320x50 banners and dynamic collapsible banners that expand to full height upon loading.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Standard Banner Section
            Text(
              "STANDARD ANCHORED BANNER",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.secondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: PreloadGoogleAds.instance.showBannerAd(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Collapsible Banner Selector & Display Section
            Text(
              "COLLAPSIBLE BANNER POSITION DEMO",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.secondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Select Collapsible Anchor Position:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SegmentedButton<CollapsibleBannerPosition>(
                      segments: const [
                        ButtonSegment(
                          value: CollapsibleBannerPosition.bottom,
                          label: Text("Bottom Collapsible"),
                          icon: Icon(Icons.vertical_align_bottom_rounded),
                        ),
                        ButtonSegment(
                          value: CollapsibleBannerPosition.top,
                          label: Text("Top Collapsible"),
                          icon: Icon(Icons.vertical_align_top_rounded),
                        ),
                      ],
                      selected: {collapsiblePosition},
                      onSelectionChanged: (set) {
                        setState(() {
                          collapsiblePosition = set.first;
                          previewKey++;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: PreloadGoogleAds.instance.showCollapsibleBannerAd(
                          key: ValueKey("col_banner_${collapsiblePosition.name}_$previewKey"),
                          collapsiblePosition: collapsiblePosition,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
