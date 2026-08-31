import 'package:flutter/material.dart';
import 'package:preload_google_ads/preload_google_ads.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'widgets/app_drawer.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/native_list_screen.dart';
import 'screens/custom_style_screen.dart';
import 'screens/banner_ad_screen.dart';
import 'screens/format_lab_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Preload Google Ads SDK with Light & Dark mode styling configuration
  await PreloadGoogleAds.instance.initialize(
    adConfigData: AdConfigData(
      nativeADLayout: NativeADLayout(
        customNativeADStyle: CustomNativeADStyle(
          titleColor: const Color(0xFF0F172A),
          bodyColor: const Color(0xFF64748B),
          buttonBackground: const Color(0xFF6366F1),
          buttonRadius: 10,
        ),
        darkCustomNativeADStyle: CustomNativeADStyle.dark(
          titleColor: const Color(0xFFF8FAFC),
          bodyColor: const Color(0xFF94A3B8),
          buttonBackground: const Color(0xFF818CF8),
          buttonRadius: 10,
        ),
        lightDecoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        darkDecoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
      ),
      bannerADLayout: BannerADLayout(
        lightDecoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        darkDecoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF334155)),
        ),
      ),
    ),
  );

  runApp(const ShowcaseApp());
}

class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key});

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  void initState() {
    super.initState();
    _themeProvider.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Preload Ads Showcase Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeProvider.themeMode,
      home: MainNavigationContainer(themeProvider: _themeProvider),
    );
  }
}

class MainNavigationContainer extends StatefulWidget {
  final ThemeProvider themeProvider;

  const MainNavigationContainer({super.key, required this.themeProvider});

  @override
  State<MainNavigationContainer> createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _currentIndex = 0;

  void _selectScreen(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeDashboardScreen(
        onNavigate: _selectScreen,
        themeProvider: widget.themeProvider,
      ),
      CustomStyleScreen(themeProvider: widget.themeProvider),
      const NativeListScreen(),
      BannerAdScreen(themeProvider: widget.themeProvider),
      const FormatLabScreen(),
    ];

    return Stack(
      children: [
        Scaffold(
          drawer: AppDrawer(
            currentIndex: _currentIndex,
            onSelectScreen: _selectScreen,
            themeProvider: widget.themeProvider,
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _selectScreen,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_outlined),
                selectedIcon: Icon(Icons.tune_rounded),
                label: 'Customizer',
              ),
              NavigationDestination(
                icon: Icon(Icons.view_list_outlined),
                selectedIcon: Icon(Icons.view_list_rounded),
                label: 'Native Feed',
              ),
              NavigationDestination(
                icon: Icon(Icons.view_stream_outlined),
                selectedIcon: Icon(Icons.view_stream_rounded),
                label: 'Banner Ads',
              ),
              NavigationDestination(
                icon: Icon(Icons.science_outlined),
                selectedIcon: Icon(Icons.science_rounded),
                label: 'Ad Lab',
              ),
            ],
          ),
        ),

        // Global Draggable Floating Metrics Overlay
        PreloadGoogleAds.instance.showAdCounter(),
      ],
    );
  }
}
