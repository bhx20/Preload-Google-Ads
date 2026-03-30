import 'package:preload_google_ads/preload_google_ads.dart';
import 'dashboard_view.dart';

/// A splash screen that initializes ads and navigates to the main dashboard.
class SplashView extends StatefulWidget {
  /// Creates a [SplashView].
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _initAds();
  }

  Future<void> _initAds() async {
    bool navigated = false;
    void navigate() {
      if (navigated || !mounted) return;
      navigated = true;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainDashboard(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }

    // Set the callback for when the splash ad is ready.
    PreloadGoogleAds.instance.setSplashAdCallback((ad, error) => navigate());

    // Fallback timer in case the ad takes too long or fails silently.
    await Future.delayed(const Duration(seconds: 2));
    if (!navigated) navigate();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.ads_click,
                size: 60,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Preload Showcase",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
