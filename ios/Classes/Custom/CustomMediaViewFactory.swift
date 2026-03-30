import Flutter
import UIKit
import GoogleMobileAds

/// Factory for the MediaView sub-platform-view.
///
/// When Flutter's AdMediaView widget needs to render the native SDK's MediaView,
/// it creates a PlatformView with type `com.plug.preload/customNativeAd_media`.
///
/// This factory looks up the parent `FlutterCustomNativeAdView` by `parentViewId`
/// from `FlutterCustomNativeAdView.registry` and returns the parent's pre-created
/// MediaView instance. This guarantees the same MediaView that the SDK populated
/// with video/image content is the one displayed in the Flutter layout.
///
/// WHY this exists:
/// The AdMob SDK requires its own MediaView for rendering video content and
/// tracking video events (start, complete, mute, etc.). A Flutter Image widget
/// cannot satisfy this requirement — only the SDK's own view can.
class CustomMediaViewFactory: NSObject, FlutterPlatformViewFactory {

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        let params = args as? [String: Any]
        let parentViewId = (params?["parentViewId"] as? NSNumber)?.intValue ?? -1

        // Look up the parent ad view to get its pre-loaded MediaView.
        let parentView = FlutterCustomNativeAdView.registry[parentViewId]

        if parentView == nil {
            NSLog("CustomMediaViewFactory: No parent FlutterCustomNativeAdView found for parentViewId=\(parentViewId). Ensure the NativeAdView platform view is created before AdMediaView. Falling back to a blank MediaView.")
        }

        return MediaPlatformView(parentView: parentView, frame: frame)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

/// Internal PlatformView wrapper that returns the parent's MediaView.
private class MediaPlatformView: NSObject, FlutterPlatformView {
    private let mediaView: MediaView

    init(parentView: FlutterCustomNativeAdView?, frame: CGRect) {
        self.mediaView = parentView?.mediaView ?? MediaView(frame: frame)
        super.init()

        mediaView.frame = frame
        mediaView.contentMode = .scaleAspectFit
    }

    func view() -> UIView {
        return mediaView
    }
}
