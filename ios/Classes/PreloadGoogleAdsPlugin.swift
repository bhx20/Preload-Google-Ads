import Flutter
import UIKit
import GoogleMobileAds
import google_mobile_ads

/**
 * PreloadGoogleAdsPlugin
 *
 * Main Flutter plugin entry point for iOS builder-only native ad architecture.
 * Mirrors the Android PreloadGoogleAdsPlugin.kt implementation.
 */
public class PreloadGoogleAdsPlugin: NSObject, FlutterPlugin {
    static var channel: FlutterMethodChannel?
    private static var customFactoryIds: [String] = []

    public static func sendAdAssets(factoryId: String, nativeAd: NativeAd) {
        let assets: [String: Any?] = [
            "factoryId": factoryId,
            "headline": nativeAd.headline,
            "body": nativeAd.body,
            "callToAction": nativeAd.callToAction,
            "advertiser": nativeAd.advertiser,
            "store": nativeAd.store,
            "price": nativeAd.price,
            "rating": nativeAd.starRating?.doubleValue,
            "images": nativeAd.images?.compactMap { $0.imageURL?.absoluteString },
            "iconBytes": FlutterStandardTypedData(bytes: nativeAd.icon?.image?.pngData() ?? Data()),
            "hasVideo": nativeAd.mediaContent.hasVideoContent,
            "duration": nativeAd.mediaContent.duration,
            "aspectRatio": Float(nativeAd.mediaContent.aspectRatio)
        ]

        channel?.invokeMethod("onAdAssetsLoaded", arguments: assets)
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: "com.plug.preload/adButtonStyle",
            binaryMessenger: registrar.messenger()
        )
        channel = methodChannel

        let instance = PreloadGoogleAdsPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)

        // Register the main custom native ad PlatformView factory.
        registrar.register(
            CustomNativeAdViewFactory(messenger: registrar.messenger()),
            withId: "com.plug.preload/customNativeAd"
        )

        // Register the sub-platform-view factories for MediaView and IconView.
        // These match Android's registration in PreloadGoogleAdsPlugin.kt:
        //   "com.plug.preload/customNativeAd_media"
        //   "com.plug.preload/customNativeAd_icon"
        registrar.register(
            CustomMediaViewFactory(),
            withId: "com.plug.preload/customNativeAd_media"
        )
        registrar.register(
            CustomIconViewFactory(),
            withId: "com.plug.preload/customNativeAd_icon"
        )
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setCustomFactoryLayouts":
            if let data = call.arguments as? [String: Any],
               let factories = data["factories"] as? [[String: Any]] {
                PreloadGoogleAdsPlugin.updateCustomFactories(factories: factories)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected factories list", details: nil))
            }

        case "preloadBuilderAd":
            if let data = call.arguments as? [String: Any],
               let adUnitId = data["adUnitId"] as? String,
               let factoryId = data["factoryId"] as? String {
                FlutterCustomNativeAdView.preloadAd(adUnitId: adUnitId, factoryId: factoryId)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected adUnitId and factoryId", details: nil))
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Registers/unregisters native ad factories via the google_mobile_ads plugin API.
    /// This matches Android's `GoogleMobileAdsPlugin.registerNativeAdFactory()` / `unregisterNativeAdFactory()`.
    ///
    /// The `FLTGoogleMobileAdsPlugin` API requires `FlutterPluginRegistry` (the AppDelegate)
    /// rather than `FlutterPluginRegistrar`, so we obtain it from `UIApplication.shared.delegate`.
    private static func updateCustomFactories(factories: [[String: Any]]) {
        guard let registry = UIApplication.shared.delegate as? FlutterPluginRegistry else {
            NSLog("PreloadGoogleAdsPlugin: AppDelegate does not conform to FlutterPluginRegistry, cannot register factories")
            return
        }

        FlutterCustomNativeAdView.clearCache()

        // Unregister all previously registered factories.
        for id in customFactoryIds {
            FLTGoogleMobileAdsPlugin.unregisterNativeAdFactory(registry, factoryId: id)
        }
        customFactoryIds.removeAll()

        // Register new factories.
        for factoryData in factories {
            guard let factoryId = factoryData["factoryId"] as? String else { continue }

            let factory = DynamicNativeAdFactory(factoryId: factoryId)
            FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
                registry,
                factoryId: factoryId,
                nativeAdFactory: factory
            )
            customFactoryIds.append(factoryId)
        }
    }
}
