import Flutter
import UIKit

/// Factory that creates `FlutterCustomNativeAdView` instances for the
/// `com.plug.preload/customNativeAd` platform view type.
///
/// Flutter's PlatformView framework calls `create` whenever a new
/// `UiKitView` with this view type appears in the widget tree.
class CustomNativeAdViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        let creationParams = args as? [String: Any]

        return FlutterCustomNativeAdView(
            frame: frame,
            viewId: Int(viewId),
            messenger: messenger,
            args: creationParams
        )
    }

    /// Tells Flutter to use [StandardMessageCodec] for creation params encoding.
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
