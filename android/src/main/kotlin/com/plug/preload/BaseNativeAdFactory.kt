package com.plug.preload

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import androidx.annotation.LayoutRes
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory

abstract class BaseNativeAdFactory(
    protected val context: Context,
    protected val styleMap: Map<String, Any>
) : NativeAdFactory {

    protected fun parseColor(hex: String?, defaultColor: Int = Color.BLACK): Int {
        if (hex.isNullOrEmpty()) return defaultColor
        return try {
            Color.parseColor(hex)
        } catch (e: IllegalArgumentException) {
            println("⚠️ Invalid color format: $hex")
            defaultColor
        }
    }

    protected fun dpToPx(dp: Int): Float {
        return dp * context.resources.displayMetrics.density
    }

    protected fun inflateAdView(@LayoutRes layoutId: Int): NativeAdView {
        return LayoutInflater.from(context).inflate(layoutId, null) as NativeAdView
    }

    protected fun populateCommonViews(nativeAdView: NativeAdView, nativeAd: NativeAd) {
        // Attribution/Tag View
        nativeAdView.findViewById<TextView>(R.id.native_ad_attribution_small)?.apply {
            visibility = View.VISIBLE
            val tagTextColor = styleMap["tag_foreground"] as? String ?: "#FFFFFF"
            setTextColor(parseColor(tagTextColor, Color.WHITE))

            val tagBackgroundColor = styleMap["tag_background"] as? String ?: "#F19938"
            val tagRadiusDp = when (val value = styleMap["tag_radius"]) {
                is Number -> value.toInt()
                is String -> value.toIntOrNull() ?: 3
                else -> 3
            }

            background = GradientDrawable().apply {
                setColor(parseColor(tagBackgroundColor, Color.parseColor("#F19938")))
                cornerRadius = dpToPx(tagRadiusDp)
            }
        }

        // Icon View
        nativeAdView.findViewById<ImageView>(R.id.native_ad_icon)?.let { iconView ->
            nativeAdView.iconView = iconView
            if (nativeAd.icon == null) {
                iconView.visibility = View.GONE
            } else {
                iconView.visibility = View.VISIBLE
                iconView.setImageDrawable(nativeAd.icon?.drawable)
            }
        }

        // Headline View
        nativeAdView.findViewById<TextView>(R.id.native_ad_headline)?.let { headlineView ->
            nativeAdView.headlineView = headlineView
            headlineView.text = nativeAd.headline
            val titleColor = styleMap["title"] as? String ?: "#000000"
            headlineView.setTextColor(parseColor(titleColor, Color.BLACK))
        }

        // Body View
        nativeAdView.findViewById<TextView>(R.id.native_ad_body)?.let { bodyView ->
            nativeAdView.bodyView = bodyView
            if (nativeAd.body == null) {
                bodyView.visibility = View.INVISIBLE
            } else {
                bodyView.visibility = View.VISIBLE
                bodyView.text = nativeAd.body
                val bodyColor = styleMap["description"] as? String ?: "#9B9B9B"
                bodyView.setTextColor(parseColor(bodyColor, Color.GRAY))
            }
        }

        // Call to Action View
        nativeAdView.findViewById<Button>(R.id.native_ad_button)?.let { button ->
            nativeAdView.callToActionView = button
            if (nativeAd.callToAction == null) {
                button.visibility = View.INVISIBLE
            } else {
                button.visibility = View.VISIBLE
                button.text = nativeAd.callToAction
                
                val foregroundColor = styleMap["button_foreground"] as? String ?: "#FFFFFF"
                button.setTextColor(parseColor(foregroundColor, Color.WHITE))

                val radiusDp = try {
                    styleMap["button_radius"]?.toString()?.toFloat() ?: 5f
                } catch (e: Exception) {
                    5f
                }
                val radiusPx = TypedValue.applyDimension(
                    TypedValue.COMPLEX_UNIT_DIP,
                    radiusDp,
                    context.resources.displayMetrics
                )

                setupButtonBackground(button, radiusPx)
            }
        }
    }

    private fun setupButtonBackground(button: Button, radiusPx: Float) {
        var backgroundSet = false
        val gradientsObj = styleMap["button_gradients"]
        if (gradientsObj is List<*>) {
            val gradientColors = gradientsObj.filterIsInstance<String>()
                .map { parseColor(it) }

            if (gradientColors.size >= 2) {
                button.background = GradientDrawable(
                    GradientDrawable.Orientation.LEFT_RIGHT,
                    gradientColors.toIntArray()
                ).apply {
                    cornerRadius = radiusPx
                }
                backgroundSet = true
            } else if (gradientColors.size == 1) {
                button.background = GradientDrawable().apply {
                    setColor(gradientColors[0])
                    cornerRadius = radiusPx
                }
                backgroundSet = true
            }
        }

        if (!backgroundSet) {
            val fallbackColor = parseColor(styleMap["button_background"] as? String, Color.parseColor("#2196F3"))
            button.background = GradientDrawable().apply {
                setColor(fallbackColor)
                cornerRadius = radiusPx
            }
        }
    }
}
