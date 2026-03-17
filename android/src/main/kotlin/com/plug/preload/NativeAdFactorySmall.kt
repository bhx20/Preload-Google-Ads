package com.plug.preload

import android.content.Context
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView

class NativeAdFactorySmall(context: Context, styleMap: Map<String, Any>) : 
    BaseNativeAdFactory(context, styleMap) {

    override fun createNativeAd(nativeAd: NativeAd, customOptions: Map<String, Any>?): NativeAdView {
        val nativeAdView = inflateAdView(R.layout.small_template)

        // Populate common views (Headline, Body, CTA, Icon, Tag)
        populateCommonViews(nativeAdView, nativeAd)

        nativeAdView.setNativeAd(nativeAd)
        return nativeAdView
    }
}
