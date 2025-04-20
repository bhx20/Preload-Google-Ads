import 'package:preload_google_ads/preload_google_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize the PreloadGoogleAds plugin
  PreloadGoogleAds.instance.initialize(
    adConfigData: AdConfigData(
      adIDs: AdIDS(
        appOpenId: AdTestIds.appOpen,
        bannerId: AdTestIds.banner,
        nativeId: AdTestIds.native,
        interstitialId: AdTestIds.interstitial,
        rewardedId: AdTestIds.rewarded,
      ),
    )
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

  List<AdTypList> adTypes = [];

  @override
  void initState() {
    ad = SizedBox();
    adTypes = [
      AdTypList(onPressed: showOpenAppAd, title: "Show Open App AD"),
      AdTypList(onPressed: showInterAd, title: "Show Interstitial AD"),
      AdTypList(onPressed: showRewardedAd, title: "Show Rewarded AD"),
      AdTypList(onPressed: showMediumNativeAd, title: "Show Medium Native AD"),
      AdTypList(onPressed: showSmallNativeAd, title: "Show Small Native AD"),
      AdTypList(onPressed: showBannerAd, title: "Show Banner AD"),
    ];
    super.initState();
  }

  /// Show native ad (small or medium based on flag)
  showNative({NativeADType nativeADType = NativeADType.medium}) {
    setState(() {
      ad = PreloadGoogleAds.instance.showNativeAd(nativeADType: nativeADType);
    });
  }

  /// Show banner ad
  showBanner() {
    setState(() {
      ad = PreloadGoogleAds.instance.showBannerAd();
    });
  }

  /// Show Open App Ad
  showOpenAppAd() => PreloadGoogleAds.instance.showOpenApp();

  /// Show Interstitial Ad with callback
  showInterAd() => PreloadGoogleAds.instance.showInterstitialAd(
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
  showRewardedAd() => PreloadGoogleAds.instance.showRewardedAd(
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
  showMediumNativeAd() => showNative();

  /// Show Small Native Ad
  showSmallNativeAd() => showNative(nativeADType: NativeADType.small);

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
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              "preload_google_ads 0.0.4",
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: GridView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
              ).copyWith(bottom: 20, top: 10),
              itemCount: adTypes.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 5,
              ),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: adTypes[index].onPressed,
                  child: Text(
                    adTypes[index].title,
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                );
              },
            ),
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
}
