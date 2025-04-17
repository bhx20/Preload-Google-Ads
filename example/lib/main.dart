import 'package:preload_google_ads/preload_google_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize the PreloadGoogleAds plugin
  PreloadGoogleAds.instance.initialize(
    adConfig: AdConfigData(adStyle: AdStyle(titleColor: Colors.orange)),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      debugShowCheckedModeBanner: false,
      home: SplashView(),
    );
  }
}

///==============================================================================
///                            **  Splash View  **
///==============================================================================

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    setSplashAdCallBack();
    super.initState();
  }

  /// Set a callback for the splash ad finish event
  setSplashAdCallBack() {
    PreloadGoogleAds.instance.setSplashAdCallback((ad, error) {
      debugPrint("Ad callback triggered, ${ad?.adUnitId}");

      /// Navigate to HomeView after splash ad completes
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeView()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Image.asset("assets/pub-dev-logo.png", height: 35),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "preload_google_ads: ^0.0.3",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LinearProgressIndicator(color: Colors.blue[300]),
            ),
          ),
        ],
      ),
    );
  }
}

///==============================================================================
///                            **  Home View  **
///==============================================================================

class AdTypList {
  final void Function() onPressed;
  final String title;

  AdTypList({required this.onPressed, required this.title});
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Widget ad;

  @override
  void initState() {
    ad = SizedBox();

    /// Placeholder for dynamic ad widget
    super.initState();
  }

  /// Show native ad (small or medium based on flag)
  showNative(bool isSmall) {
    setState(() {
      ad = Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey..withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.all(5),
        child: PreloadGoogleAds.instance.showNativeAd(isSmall: isSmall),
      );
    });
  }

  /// Show banner ad
  showBanner() {
    setState(() {
      ad = PreloadGoogleAds.instance.showBannerAd();
    });
  }

  /// Reusable button widget
  Widget _button({
    required String text,
    required VoidCallback onPressed,
    double width = 180,
    Color backgroundColor = Colors.blue,
    Color textColor = Colors.white,
    double borderRadius = 8.0,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 12.0),
    EdgeInsetsGeometry margin = const EdgeInsets.all(8.0),
  }) {
    return Container(
      width: width,
      margin: margin,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  /// Show Open App Ad
  showOpenAppAd() => PreloadGoogleAds.instance.showOpenApp();

  /// Show Interstitial Ad with callback
  showInterAd() => PreloadGoogleAds.instance.showAdInterstitialAd(
    callBack: (ad, error) {
      if (ad != null) {
        debugPrint("Inter AD loaded successfully!");
        debugPrint(ad.adUnitId);
      } else {
        debugPrint("Inter Ad failed to load: ${error?.message}");
      }
    },
  );

  /// Show Rewarded Ad with callback and reward handler
  showRewardedAd() => PreloadGoogleAds.instance.showAdRewardedAd(
    callBack: (ad, error) {
      if (ad != null) {
        debugPrint("Ad loaded successfully!");
      } else {
        debugPrint("Ad failed to load: ${error?.message}");
      }
    },
    onReward: (ad, reward) {
      debugPrint("User earned reward: ${reward.amount} ${reward.type}");
    },
  );

  /// Show Medium Native Ad
  showMediumNativeAd() => showNative(false);

  /// Show Small Native Ad
  showSmallNativeAd() => showNative(true);

  /// Show Banner Ad
  showBannerAd() => showBanner();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Image.asset("assets/pub-dev-logo.png"),
        ),
        leadingWidth: 120,
        actions: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "preload_google_ads 0.0.3",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: "preload_google_ads: ^0.0.3"),
                  ).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Pub copied to clipboard'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  });
                },
                icon: Icon(Icons.copy, color: Colors.white, size: 15),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Column(
            children: [
              _button(onPressed: showOpenAppAd, text: "Show Open App AD"),
              _button(onPressed: showInterAd, text: "Show Interstitial AD"),
              _button(onPressed: showRewardedAd, text: "Show Rewarded AD"),
              _button(
                onPressed: showMediumNativeAd,
                text: "Show Medium Native AD",
              ),
              _button(
                onPressed: showSmallNativeAd,
                text: "Show Small Native AD",
              ),
              _button(onPressed: showBannerAd, text: "Show Banner AD"),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ad,
                PreloadGoogleAds.instance.showAdCounter(showCounter: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //
  // List<AdTypList>  adTypes = [
  //   AdTypList(onPressed:showOpenAppAd,title:"Show Open App AD"  ),
  //   AdTypList(onPressed:showInterAd,title:"Show Interstitial AD"  ),
  //   AdTypList(onPressed:showRewardedAd,title:"Show Rewarded AD"  ),
  //   AdTypList(onPressed:showMediumNativeAd,title:"Show Medium Native AD" ),
  //   AdTypList(onPressed:showSmallNativeAd,title:"Show Small Native AD"  ),
  //   AdTypList(onPressed:showBannerAd,title: "Show Banner AD"  ),
  // ];
}
