import 'package:flutter/material.dart';
import 'package:preload_google_ads/preload_google_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize the PreloadGoogleAds plugin
  PreloadGoogleAds.instance.initialize();
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
      builder: (context, child) {
        /// Wrap the app with an ad counter overlay
        return Scaffold(
          body: Column(
            children: [
              Expanded(child: child ?? SizedBox()),
              PreloadGoogleAds.instance.showAdCounter(showCounter: true),
            ],
          ),
        );
      },
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
      body: Column(
        children: [
          Expanded(child: Center(child: Text("Splash"))),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
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
        leading: SizedBox(),
        title: Text(
          "PreLoad Google Ads".toUpperCase(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
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
              children: [ad],
            ),
          ),
        ],
      ),
    );
  }
}
