package com.plug.preload

import android.content.Context
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView

class NativeAdFactoryMedium(context: Context, styleMap: Map<String, Any>) : 
    BaseNativeAdFactory(context, styleMap) {

    override fun createNativeAd(nativeAd: NativeAd, customOptions: Map<String, Any>?): NativeAdView {
        val nativeAdView = inflateAdView(R.layout.medium_template)

        // Populate common views (Headline, Body, CTA, Icon, Tag)
        populateCommonViews(nativeAdView, nativeAd)

        // Medium specific: Media View
        nativeAdView.findViewById<MediaView>(R.id.native_ad_media)?.let { mediaView ->
            mediaView.setMediaContent(nativeAd.mediaContent)
            nativeAdView.mediaView = mediaView
        }

        nativeAdView.setNativeAd(nativeAd)
        return nativeAdView
    }
}
