import google_mobile_ads
import preload_google_ads

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Register Native Ad Factories
    let smallFactory = NativeAdFactorySmall()
    let mediumFactory = NativeAdFactoryMedium()
    
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        self, factoryId: "small_native", nativeAdFactory: smallFactory)
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        self, factoryId: "medium_native", nativeAdFactory: mediumFactory)
        
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
