import Flutter
import UIKit

public class PreloadGoogleAdsPlugin: NSObject, FlutterPlugin {
  static var channel: FlutterMethodChannel?
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    channel = FlutterMethodChannel(name: "com.plug.preload/adButtonStyle", binaryMessenger: registrar.messenger())
    let instance = PreloadGoogleAdsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel!)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setAdStyle":
      if let arguments = call.arguments as? [String: Any] {
        // In a real iOS implementation, we would store this style
        // and use it when creating the native ad views.
        // For now, we'll just acknowledge receipt.
        NotificationCenter.default.post(name: NSNotification.Name("PreloadGoogleAds_UpdateStyle"), object: nil, userInfo: arguments)
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected a style map", details: nil))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
