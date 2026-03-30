import Flutter
import UIKit

/// Factory for the icon UIImageView sub-platform-view.
///
/// When Flutter's AdIconView widget needs to render the native ad icon,
/// it creates a PlatformView with type `com.plug.preload/customNativeAd_icon`.
///
/// This factory looks up the parent `FlutterCustomNativeAdView` by `parentViewId`
/// from `FlutterCustomNativeAdView.registry` and returns the parent's pre-loaded
/// `UIImageView` (which already has the ad's icon image set).
///
/// WHY this exists:
/// While developers CAN use NativeAdData.iconBytes to render the icon as a
/// Flutter Image widget, using this platform view ensures the SDK properly
/// registers the icon view for click tracking — which is required for full
/// SDK compliance and accurate click attribution.
class CustomIconViewFactory: NSObject, FlutterPlatformViewFactory {

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        let params = args as? [String: Any]
        let parentViewId = (params?["parentViewId"] as? NSNumber)?.intValue ?? -1

        // Look up the parent ad view to get its icon UIImageView.
        let parentView = FlutterCustomNativeAdView.registry[parentViewId]

        if parentView == nil {
            NSLog("CustomIconViewFactory: No parent FlutterCustomNativeAdView found for parentViewId=\(parentViewId). Ensure the NativeAdView platform view is created before AdIconView. Falling back to a blank UIImageView.")
        }

        return IconPlatformView(parentView: parentView, frame: frame)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

/// Internal PlatformView wrapper that returns the parent's icon UIImageView.
private class IconPlatformView: NSObject, FlutterPlatformView {
    private let iconView: UIImageView

    init(parentView: FlutterCustomNativeAdView?, frame: CGRect) {
        self.iconView = parentView?.iconImageView ?? UIImageView(frame: frame)
        super.init()

        iconView.frame = frame
        iconView.contentMode = .scaleAspectFill
        iconView.clipsToBounds = true
    }

    func view() -> UIView {
        return iconView
    }
}
