package com.plug.preload

import android.content.Context
import android.graphics.Color
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import androidx.constraintlayout.widget.ConstraintLayout
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory

/**
 * A builder-only Native Ad Factory.
 * It creates a transparent NativeAdView that serves as a click-tracker
 * for the assets rendered in Flutter.
 */
class DynamicNativeAdFactory(
    private val context: Context,
    private val factoryId: String
) : NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val nativeAdView = NativeAdView(context)
        nativeAdView.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )

        val root = ConstraintLayout(context).apply {
            id = View.generateViewId()
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        }
        nativeAdView.addView(root)

        // Transparent clickable overlay to catch clicks on the native side.
        val overlay = Button(context).apply {
            id = View.generateViewId()
            setBackgroundColor(Color.TRANSPARENT)
            layoutParams = ConstraintLayout.LayoutParams(
                ConstraintLayout.LayoutParams.MATCH_PARENT,
                ConstraintLayout.LayoutParams.MATCH_PARENT
            )
        }
        root.addView(overlay)
        nativeAdView.callToActionView = overlay

        nativeAdView.setNativeAd(nativeAd)

        // Send assets to Flutter via the plugin channel
        PreloadGoogleAdsPlugin.sendAdAssets(factoryId, nativeAd)

        return nativeAdView
    }
}
