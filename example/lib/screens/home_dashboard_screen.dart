import 'package:flutter/material.dart';
import 'package:preload_google_ads/preload_google_ads.dart';
import '../theme/theme_provider.dart';

class HomeDashboardScreen extends StatelessWidget {
  final Function(int) onNavigate;
  final ThemeProvider themeProvider;

  const HomeDashboardScreen({
    super.key,
    required this.onNavigate,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeProvider.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Preload Ads Showcase Studio"),
        actions: [
          IconButton(
            tooltip: isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.amber : Colors.indigo,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Welcome Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [const Color(0xFF312E81), const Color(0xFF1E1B4B)]
                      : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "v1.0.7 Live Performance Suite",
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "High-Performance Preloaded Ad Engine",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Zero-latency ad display with seamless native integration for Flutter.",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Use Cases Showcase Grid
            Text(
              "SHOWCASE USE CASES",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.secondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            _useCaseCard(
              context,
              "ListView Feed & Pagination",
              "Inline Small Native Ads automatically inserted into an infinite scroll feed.",
              Icons.view_list_rounded,
              Colors.indigo,
              () => onNavigate(1),
            ),
            const SizedBox(height: 12),

            _useCaseCard(
              context,
              "Native Ad Style Customizer",
              "Tweak primary colors, border radiuses, and backgrounds dynamically.",
              Icons.tune_rounded,
              Colors.amber[800]!,
              () => onNavigate(2),
            ),
            const SizedBox(height: 12),

            _useCaseCard(
              context,
              "Ad Format Test Lab",
              "Trigger Interstitial, Rewarded, Collapsible Banner, and App Open ads.",
              Icons.science_rounded,
              Colors.purple,
              () => onNavigate(3),
            ),
            const SizedBox(height: 24),

            // Persistent Banner Preview
            Text(
              "PERSISTENT ANCHORED BANNER",
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
                padding: const EdgeInsets.all(8.0),
                child: PreloadGoogleAds.instance.showBannerAd(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _useCaseCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: const TextStyle(fontSize: 12)),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
