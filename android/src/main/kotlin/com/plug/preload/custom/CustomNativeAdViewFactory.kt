package com.plug.preload.custom

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * Factory that creates [FlutterCustomNativeAdView] instances for the
 * platform view type `com.plug.preload/customNativeAd`.
 *
 * Flutter's PlatformView framework calls [create] whenever a new
 * AndroidView / PlatformViewLink with this viewType appears in the widget tree.
 *
 * The [creationParams] map is passed from Flutter's NativeAdView widget and
 * must contain at minimum:
 *   - "adUnitId" (String) : the AdMob ad unit ID to load
 *
 * The [viewId] is a unique integer assigned by the Flutter engine for each
 * platform view instance. It is used as:
 *   1. The suffix on the MethodChannel name → "com.plug.preload/customNativeAd/{viewId}"
 *      so each ad instance has its own isolated communication channel.
 *   2. The key in [FlutterCustomNativeAdView.registry] so sub-platform-views
 *      (MediaView, IconView) can find their parent ad view.
 */
class CustomNativeAdViewFactory(
    private val messenger: BinaryMessenger
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val creationParams = args as? Map<String, Any?>

        return FlutterCustomNativeAdView(
            context = context,
            viewId = viewId,
            messenger = messenger,
            creationParams = creationParams
        )
    }
}