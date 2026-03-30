package com.plug.preload.custom

import android.content.Context
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * Factory for the icon ImageView sub-platform-view.
 *
 * When Flutter's AdIconView widget needs to render the native ad icon,
 * it creates a PlatformView with type `com.plug.preload/customNativeAd_icon`.
 *
 * This factory looks up the parent [FlutterCustomNativeAdView] by `parentViewId`
 * from [FlutterCustomNativeAdView.registry] and returns the parent's pre-loaded
 * [ImageView] (which already has the ad's icon drawable set).
 *
 * WHY this exists:
 * While developers CAN use NativeAdData.iconBytes to render the icon as a
 * Flutter Image widget, using this platform view ensures the SDK properly
 * registers the icon view for click tracking — which is required for full
 * SDK compliance and accurate click attribution.
 *
 * FIX: Added null-safety log when parentView is not found in registry.
 *      This helps catch timing issues during development where the sub-view
 *      is created before the parent FlutterCustomNativeAdView is registered.
 */
class CustomIconViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    companion object {
        private const val TAG = "CustomIconViewFactory"
    }

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val params = args as? Map<String, Any?>
        val parentViewId = (params?.get("parentViewId") as? Number)?.toInt() ?: -1

        // Look up the parent ad view to get its icon ImageView.
        val parentView = FlutterCustomNativeAdView.registry[parentViewId]

        // FIX: Log a clear error if the parent is missing so developers can
        // diagnose registry timing issues during development.
        if (parentView == null) {
            Log.e(
                TAG,
                "No parent FlutterCustomNativeAdView found for parentViewId=$parentViewId. " +
                        "Ensure the NativeAdView platform view is created before AdIconView. " +
                        "Falling back to a blank ImageView."
            )
        }

        return object : PlatformView {
            override fun getView(): View {
                val iconView = parentView?.iconImageView ?: ImageView(context)

                // A View can only have one parent at a time in Android.
                // Detach from any existing parent before returning.
                (iconView.parent as? ViewGroup)?.removeView(iconView)

                iconView.layoutParams = ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
                )

                // CENTER_CROP ensures the icon image fills the view cleanly
                // without distortion, even if aspect ratios don't match exactly.
                iconView.scaleType = ImageView.ScaleType.CENTER_CROP

                return iconView
            }

            override fun dispose() {
                // Icon lifecycle is fully managed by the parent FlutterCustomNativeAdView.
                // We must NOT destroy it here — the parent manages its lifecycle.
            }
        }
    }
}