import 'package:flutter/material.dart';
import 'package:preload_google_ads/preload_ad.dart';

void main() {
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
      home: SplashView(),
      builder: (context, child) {
        return Column(
          children: [
            Expanded(child: child ?? SizedBox()),
            PreloadAds.instance.showAdCounter(showCounter: true),
          ],
        );
      },
    );
  }
}

//==============================================================================
//                            **  Splash View  **
//==============================================================================

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    getAds();
    super.initState();
  }

  getAds() {
    PreloadAds.instance.initialize(
      onAdStartAdCallBack: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeView()),
        );
      },
    );
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

//==============================================================================
//                            **  Home View  **
//==============================================================================

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
    super.initState();
  }

  showNative(bool isSmall) {
    setState(() {
      ad = Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.all(5),
        child: PreloadAds.instance.showNativeAd(isSmall: isSmall),
      );
    });
  }

  showBanner() {
    setState(() {
      ad = PreloadAds.instance.showBannerAd();
    });
  }

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

  showOpenAppAd() => PreloadAds.instance.showOpenApp();

  showInterAd() => PreloadAds.instance.showAdInterstitialAd(callBack: () {});

  showRewardedAd() =>
      PreloadAds.instance.showAdRewardedAd(callBack: () {}, onReward: () {});

  showMediumNativeAd() => showNative(false);

  showSmallNativeAd() => showNative(true);

  showBannerAd() => showBanner();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: SizedBox(),
        title: Text(
          "PreLoad Google Ads",
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
              _button(onPressed: showOpenAppAd, text: "Show Open App Ad"),
              _button(onPressed: showInterAd, text: "Show interstitial Ad"),
              _button(onPressed: showRewardedAd, text: "Show Rewarded Ad"),
              _button(
                onPressed: showMediumNativeAd,
                text: "Show Medium Native Ad",
              ),
              _button(
                onPressed: showSmallNativeAd,
                text: "Show Small Native Ad",
              ),
              _button(onPressed: showBannerAd, text: "Show Banner Ad"),
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
