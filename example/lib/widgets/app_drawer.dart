import 'package:flutter/material.dart';
import 'package:preload_google_ads/preload_google_ads.dart';
import '../theme/theme_provider.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onSelectScreen;
  final ThemeProvider themeProvider;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onSelectScreen,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeProvider.isDarkMode(context);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF312E81), const Color(0xFF1E1B4B)]
                    : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.adb_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Preload Ads",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Showcase Studio",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded),
            title: const Text("Dashboard"),
            selected: currentIndex == 0,
            onTap: () {
              Navigator.pop(context);
              onSelectScreen(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_list_rounded),
            title: const Text("Native Ads in ListView"),
            subtitle: const Text("Pagination & Inline Ads"),
            selected: currentIndex == 1,
            onTap: () {
              Navigator.pop(context);
              onSelectScreen(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.grid_view_rounded),
            title: const Text("Native Ads in GridView"),
            subtitle: const Text("Card Feed & Pagination"),
            selected: currentIndex == 2,
            onTap: () {
              Navigator.pop(context);
              onSelectScreen(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.tune_rounded),
            title: const Text("Native Style Customizer"),
            selected: currentIndex == 3,
            onTap: () {
              Navigator.pop(context);
              onSelectScreen(3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.science_rounded),
            title: const Text("Ad Format Test Lab"),
            selected: currentIndex == 4,
            onTap: () {
              Navigator.pop(context);
              onSelectScreen(4);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.amber : Colors.indigo,
            ),
            title: Text(isDark ? "Switch to Light Mode" : "Switch to Dark Mode"),
            onTap: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
    );
  }
}
