import 'package:preload_google_ads/preload_google_ads.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the Preload AD SDK with custom configuration.
  await PreloadGoogleAds.instance.initialize(
    adConfigData: AdConfigData(
      adIDs: AdIDS(
        appOpenId: AdTestIds.appOpen,
        bannerId: AdTestIds.banner,
        nativeId: AdTestIds.native,
        interstitialId: AdTestIds.interstitial,
        rewardedId: AdTestIds.rewarded,
        customFactories: [
          NativeAdFactoryConfig(
            factoryId: "builder_custom",
            isBuilder: true,
          ),
        ],
      ),
    ),
  );

  runApp(const MyApp());
}
