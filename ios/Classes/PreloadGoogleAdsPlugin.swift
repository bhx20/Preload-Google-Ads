import Flutter
import UIKit
import GoogleMobileAds

@objc public class PreloadGoogleAdsPlugin: NSObject, FlutterPlugin {

    private var channel: FlutterMethodChannel?
    private var adStyleChannel: FlutterMethodChannel?
    private var preloadedAds: [String: NativeAd] = [:]
    private var adDelegates: [String: NativeAdDelegate] = [:]

    public static func register(with registrar: FlutterPluginRegistrar) {
        // Main plugin channel
        let channel = FlutterMethodChannel(name: "preload_google_ads", binaryMessenger: registrar.messenger())

        // Ad style channel - matching your constant
        let adStyleChannel = FlutterMethodChannel(name: "com.plug.preload/adButtonStyle", binaryMessenger: registrar.messenger())

        let instance = PreloadGoogleAdsPlugin()
        instance.channel = channel
        instance.adStyleChannel = adStyleChannel

        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addMethodCallDelegate(instance, channel: adStyleChannel)

        // Initialize Google Mobile Ads SDK
        MobileAds.shared.start { _ in
            print("✅ Google Mobile Ads SDK initialized")
        }

        print("ℹ️ Plugin registered. Native ad factories should be registered in AppDelegate.")
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "preloadNativeAd":
            handlePreloadNativeAd(call: call, result: result)
        case "showPreloadedAd":
            handleShowPreloadedAd(call: call, result: result)
        case "disposePreloadedAd":
            handleDisposePreloadedAd(call: call, result: result)
        case "setAdStyle": // Matching your nativeMethod constant
            handleSetAdStyle(call: call, result: result)
        case "createNativeAdView":
            handleCreateNativeAdView(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleSetAdStyle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Handle ad style configuration
        if let arguments = call.arguments as? [String: Any] {
            print("iOS: Setting ad style with arguments: \(arguments)")
            result("iOS: Ad style configured successfully")
        } else {
            result("iOS: Ad style configured with default settings")
        }
    }

    private func handleCreateNativeAdView(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let template = arguments["template"] as? String,
              let adKey = arguments["adKey"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing template or adKey", details: nil))
            return
        }

        // Get preloaded ad
        guard let nativeAd = preloadedAds[adKey] else {
            result(FlutterError(code: "AD_NOT_AVAILABLE", message: "No preloaded ad found for key: \(adKey)", details: nil))
            return
        }

        // Create appropriate view based on template using factory
        let factory: NativeAdsFactory
        switch template.lowercased() {
        case "medium":
            factory = NativeAdsFactory(nibName: "MNativeView")
        case "small":
            factory = NativeAdsFactory(nibName: "SNativeView")
        default:
            result(FlutterError(code: "INVALID_TEMPLATE", message: "Unknown template: \(template)", details: nil))
            return
        }

        if let adView = factory.createNativeAdView(with: nativeAd) {
            result("iOS: Native ad view created successfully for template: \(template)")
        } else {
            result(FlutterError(code: "VIEW_CREATION_FAILED", message: "Failed to create native ad view", details: nil))
        }
    }

    private func handlePreloadNativeAd(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let adUnitId = arguments["adUnitId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing adUnitId", details: nil))
            return
        }

        let adKey = arguments["adKey"] as? String ?? adUnitId

        // Get root view controller
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            result(FlutterError(code: "NO_ROOT_VC", message: "No root view controller found", details: nil))
            return
        }

        // Create ad loader
        let adLoader = AdLoader(
            adUnitID: adUnitId,
            rootViewController: rootViewController,
            adTypes: [.native],
            options: nil
        )

        // Create delegate
        let delegate = NativeAdDelegate { [weak self] nativeAd in
            DispatchQueue.main.async {
                if let ad = nativeAd {
                    self?.preloadedAds[adKey] = ad
                    result("iOS: Native ad preloaded successfully for key: \(adKey)")
                } else {
                    result(FlutterError(code: "AD_LOAD_FAILED", message: "Failed to load native ad", details: nil))
                }
                self?.adDelegates.removeValue(forKey: adKey)
            }
        }

        // Store delegate to prevent deallocation
        adDelegates[adKey] = delegate
        adLoader.delegate = delegate
        adLoader.load(Request())
    }

    private func handleShowPreloadedAd(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let adKey = arguments["adKey"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing adKey", details: nil))
            return
        }

        if preloadedAds[adKey] != nil {
            result("iOS: Showing preloaded ad for key: \(adKey)")
        } else {
            result(FlutterError(code: "AD_NOT_AVAILABLE", message: "No preloaded ad found for key: \(adKey)", details: nil))
        }
    }

    private func handleDisposePreloadedAd(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let adKey = arguments["adKey"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing adKey", details: nil))
            return
        }

        preloadedAds.removeValue(forKey: adKey)
        adDelegates.removeValue(forKey: adKey)
        result("iOS: Disposed preloaded ad for key: \(adKey)")
    }

    deinit {
        channel?.setMethodCallHandler(nil)
        adStyleChannel?.setMethodCallHandler(nil)
        preloadedAds.removeAll()
        adDelegates.removeAll()
    }
}

// MARK: - Native Ad Delegate
class NativeAdDelegate: NSObject, AdLoaderDelegate, NativeAdLoaderDelegate {

    private let completion: (NativeAd?) -> Void

    init(completion: @escaping (NativeAd?) -> Void) {
        self.completion = completion
        super.init()
    }

    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        completion(nativeAd)
    }

    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        print("Native ad failed to load: \(error.localizedDescription)")
        completion(nil)
    }
}

// MARK: - UIView Extension for XIB Loading
extension UIView {
    static func fromNib<T: UIView>() -> T? {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: String(describing: T.self), bundle: bundle)
        return nib.instantiate(withOwner: nil, options: nil).first as? T
    }
}
