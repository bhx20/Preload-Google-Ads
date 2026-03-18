import 'package:preload_google_ads/preload_google_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PreloadGoogleAds.instance.initialize(
    adConfigData: AdConfigData(
      adIDs: AdIDS(
        appOpenId: AdTestIds.appOpen,
        bannerId: AdTestIds.banner,
        nativeId: AdTestIds.native,
        interstitialId: AdTestIds.interstitial,
        rewardedId: AdTestIds.rewarded,
      ),
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Preload Ads Showcase',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashView(),
    );
  }
}

class SplashView extends StatefulWidget {
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
          pageBuilder: (context, animation, secondaryAnimation) => const MainDashboard(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
    PreloadGoogleAds.instance.setSplashAdCallback((ad, error) => navigate());
    await Future.delayed(const Duration(seconds: 2));
    if (!navigated) navigate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiary],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.ads_click, size: 60, color: Color(0xFF6366F1)),
            ),
            const SizedBox(height: 32),
            const Text(
              "Preload Showcase",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  Widget? currentAd;
  String currentAdTypeLabel = "No Ad Selected";
  Color primaryColor = const Color(0xFF6366F1);
  Color cardBg = Colors.white;
  double radius = 12;
  bool isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ad Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_rounded),
            onPressed: _showStyleDialog,
          ),
          const SizedBox(width: 8),
        ],
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
                        Text("Live Preview: $currentAdTypeLabel",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(radius),
                          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isRefreshing
                              ? const Center(child: CircularProgressIndicator())
                              : (currentAd != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(radius),
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
      childAspectRatio: 1.2,
      children: [
        _formatIcon(Icons.fullscreen, "Inter", Colors.blue,
                () => PreloadGoogleAds.instance.showInterstitialAd(
              callBack: (ad, error) => _handleAdCallback("Interstitial", ad, error),
            )),
        _formatIcon(Icons.stars, "Reward", Colors.orange,
                () => PreloadGoogleAds.instance.showRewardedAd(
              callBack: (ad, error) => _handleAdCallback("Rewarded", ad, error),
              onReward: (a, r) => _showSnackBar("Success! Reward: ${r.amount} ${r.type}"),
            )),
        _formatIcon(Icons.launch, "Open", Colors.purple,
                () => PreloadGoogleAds.instance.showOpenApp()),
        _formatIcon(Icons.view_stream, "Banner", Colors.green,
                () => _setAd(PreloadGoogleAds.instance.showBannerAd(), "Banner")),
        _formatIcon(Icons.ad_units, "Small", Colors.teal,
                () => _setAd(PreloadGoogleAds.instance.showNativeAd(nativeADType: NativeADType.small,), "Small Native")),
        _formatIcon(Icons.featured_play_list, "Medium", Colors.indigo,
                () => _setAd(PreloadGoogleAds.instance.showNativeAd(nativeADType: NativeADType.medium,), "Medium Native")),
      ],
    );
  }

  Widget _formatIcon(IconData icon, String label, Color color, VoidCallback onTap) {
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
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPreview(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.ads_click, size: 40, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
        const SizedBox(height: 8),
        Text("Select Format", style: TextStyle(color: theme.colorScheme.outline)),
      ],
    );
  }

  void _setAd(Widget ad, String label) {
    setState(() {
      currentAd = ad;
      currentAdTypeLabel = label;
    });
  }

  void _showStyleDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text("Customize Style"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _colorPicker("Button", primaryColor, (c) => setDialogState(() => primaryColor = c)),
              _colorPicker("Card BG", cardBg, (c) => setDialogState(() => cardBg = c)),
              const SizedBox(height: 16),
              const Text("Radius", style: TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: radius,
                min: 0,
                max: 30,
                onChanged: (v) => setDialogState(() => radius = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _applyChanges();
              },
              child: const Text("Apply"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorPicker(String label, Color color, Function(Color) onSelect) {
    return ListTile(
      dense: true,
      title: Text(label),
      trailing: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.grey.withValues(alpha: 0.2))),
      ),
      onTap: () {
        final newColor = color == const Color(0xFF6366F1) ? Colors.pink : (color == Colors.pink ? Colors.teal : const Color(0xFF6366F1));
        onSelect(newColor);
      },
    );
  }

  Future<void> _applyChanges() async {
    setState(() => isRefreshing = true);

    await PreloadGoogleAds.instance.initialize(
      adConfigData: AdConfigData(
        nativeADLayout: NativeADLayout(
          customNativeADStyle: CustomNativeADStyle(
            buttonBackground: primaryColor,
            buttonRadius: radius.toInt(),
          ),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        isRefreshing = false;
        if (currentAdTypeLabel == "Small Native") {
          currentAd = PreloadGoogleAds.instance.showNativeAd(nativeADType: NativeADType.small,);
        } else if (currentAdTypeLabel == "Medium Native") {
          currentAd = PreloadGoogleAds.instance.showNativeAd(nativeADType: NativeADType.medium,);
        } else if (currentAdTypeLabel == "Banner") {
          currentAd = PreloadGoogleAds.instance.showBannerAd();
        }
      });
    }
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
