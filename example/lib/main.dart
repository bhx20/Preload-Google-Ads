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
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PreLoad Google Ads"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                PreloadAds.instance.showAdInterstitialAd(callBack: () {});
              },
              child: Text(("Show interstitial Ad")),
            ),
          ],
        ),
      ),
    );
  }
}
