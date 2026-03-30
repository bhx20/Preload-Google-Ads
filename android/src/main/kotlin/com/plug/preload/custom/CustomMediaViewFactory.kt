package com.plug.preload.custom

import android.content.Context
import android.util.Log
import android.view.View
import android.view.ViewGroup
import com.google.android.gms.ads.nativead.MediaView
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * Factory for the MediaView sub-platform-view.
 *
 * When Flutter's AdMediaView widget needs to render the native SDK's [MediaView],
 * it creates a PlatformView with type `com.plug.preload/customNativeAd_media`.
 *
 * This factory looks up the parent [FlutterCustomNativeAdView] by `parentViewId`
 * from [FlutterCustomNativeAdView.registry] and returns the parent's pre-created
 * [MediaView] instance. This guarantees the same MediaView that the SDK populated
 * with video/image content is the one displayed in the Flutter layout.
 *
 * WHY this exists:
 * The AdMob SDK requires its own [MediaView] for rendering video content and
 * tracking video events (start, complete, mute, etc.). A Flutter Image widget
 * cannot satisfy this requirement — only the SDK's own view can.
 *
 * FIX: Added null-safety log when parentView is not found in registry.
 *      This helps catch timing issues during development where the sub-view
 *      is created before the parent FlutterCustomNativeAdView is registered.
 */
class CustomMediaViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    companion object {
        private const val TAG = "CustomMediaViewFactory"
    }

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val params = args as? Map<String, Any?>
        val parentViewId = (params?.get("parentViewId") as? Number)?.toInt() ?: -1

        // Look up the parent ad view to get its pre-loaded MediaView.
        val parentView = FlutterCustomNativeAdView.registry[parentViewId]

        // FIX: Log a clear error if the parent is missing so developers can
        // diagnose registry timing issues during development.
        if (parentView == null) {
            Log.e(
                TAG,
                "No parent FlutterCustomNativeAdView found for parentViewId=$parentViewId. " +
                        "Ensure the NativeAdView platform view is created before AdMediaView. " +
                        "Falling back to a blank MediaView."
            )
        }

        return object : PlatformView {
            override fun getView(): View {
                val mediaView = parentView?.mediaView ?: MediaView(context)

                // A View can only have one parent at a time in Android.
                // Detach from any existing parent before returning.
                (mediaView.parent as? ViewGroup)?.removeView(mediaView)

                mediaView.layoutParams = ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
                )

                return mediaView
            }

            override fun dispose() {
                // MediaView lifecycle is fully managed by the parent FlutterCustomNativeAdView.
                // We must NOT destroy it here — the parent may still need it for video tracking.
            }
        }
    }
}