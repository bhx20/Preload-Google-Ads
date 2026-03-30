package com.plug.preload

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Log
import com.google.android.gms.ads.nativead.NativeAd
import com.plug.preload.custom.CustomIconViewFactory
import com.plug.preload.custom.CustomMediaViewFactory
import com.plug.preload.custom.CustomNativeAdViewFactory
import com.plug.preload.custom.FlutterCustomNativeAdView
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import java.io.ByteArrayOutputStream

/**
 * PreloadGoogleAdsPlugin
 *
 * Main Flutter plugin entry point for the builder-only native ad architecture.
 */
class PreloadGoogleAdsPlugin : FlutterPlugin {

    private var context: Context? = null
    private var channel: MethodChannel? = null
    private var pluginBinding: FlutterPluginBinding? = null

    companion object {
        private const val TAG = "PreloadGoogleAdsPlugin"
        private const val CHANNEL_NAME = "com.plug.preload/adButtonStyle"
        private const val METHOD_SET_CUSTOM_LAYOUTS = "setCustomFactoryLayouts"

        private val customFactoryIds = mutableListOf<String>()
        private var staticChannel: MethodChannel? = null

        fun sendAdAssets(factoryId: String, nativeAd: NativeAd) {
            val channel = staticChannel ?: run {
                Log.w(TAG, "sendAdAssets called but staticChannel is null. Was the plugin attached?")
                return
            }

            val assets = mutableMapOf<String, Any?>(
                "factoryId" to factoryId,
                "headline" to nativeAd.headline,
                "body" to nativeAd.body,
                "callToAction" to nativeAd.callToAction,
                "advertiser" to nativeAd.advertiser,
                "store" to nativeAd.store,
                "price" to nativeAd.price,
                "rating" to nativeAd.starRating,
                "hasVideo" to (nativeAd.mediaContent?.hasVideoContent() ?: false),
                "duration" to (nativeAd.mediaContent?.duration ?: 0.0),
                "aspectRatio" to (nativeAd.mediaContent?.aspectRatio ?: 0.0)
            )

            val images = nativeAd.images.mapNotNull { it.uri?.toString() }
            assets["images"] = images

            nativeAd.icon?.drawable?.let { drawable ->
                assets["iconBytes"] = drawableToByteArray(drawable)
            }

            channel.invokeMethod("onAdAssetsLoaded", assets)
        }

        private fun drawableToByteArray(drawable: Drawable): ByteArray {
            val bitmap = if (drawable is BitmapDrawable) {
                drawable.bitmap
            } else {
                val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 100
                val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 100
                val bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                val canvas = Canvas(bmp)
                drawable.setBounds(0, 0, canvas.width, canvas.height)
                drawable.draw(canvas)
                bmp
            }
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            return stream.toByteArray()
        }
    }

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        context = binding.applicationContext
        pluginBinding = binding

        val methodChannel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel = methodChannel
        staticChannel = methodChannel

        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_SET_CUSTOM_LAYOUTS -> {
                    val arguments = call.arguments
                    if (arguments is Map<*, *>) {
                        @Suppress("UNCHECKED_CAST")
                        val data = arguments as Map<String, Any>
                        val factories = data["factories"] as? List<Map<String, Any>>
                        if (factories != null) {
                            updateCustomFactories(binding, factories)
                            result.success(null)
                        } else {
                            result.error("INVALID_ARGUMENT", "Expected factories list", null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Expected a map", null)
                    }
                }

                "preloadBuilderAd" -> {
                    val adUnitId = call.argument<String>("adUnitId")
                    val factoryId = call.argument<String>("factoryId")
                    val ctx = context

                    if (adUnitId != null && factoryId != null && ctx != null) {
                        preloadBuilderAd(ctx, adUnitId, factoryId)
                        result.success(null)
                    } else {
                        result.error(
                            "INVALID_ARGUMENT",
                            "Expected non-null adUnitId and factoryId",
                            null
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }

        binding.platformViewRegistry.registerViewFactory(
            "com.plug.preload/customNativeAd",
            CustomNativeAdViewFactory(binding.binaryMessenger)
        )
        binding.platformViewRegistry.registerViewFactory(
            "com.plug.preload/customNativeAd_media",
            CustomMediaViewFactory()
        )
        binding.platformViewRegistry.registerViewFactory(
            "com.plug.preload/customNativeAd_icon",
            CustomIconViewFactory()
        )
    }

    private fun preloadBuilderAd(context: Context, adUnitId: String, factoryId: String) {
        FlutterCustomNativeAdView.preloadAd(context, adUnitId, factoryId)
    }

    private fun updateCustomFactories(binding: FlutterPluginBinding, factories: List<Map<String, Any>>) {
        val engine = binding.flutterEngine
        val ctx = context ?: return
        FlutterCustomNativeAdView.clearCache()

        synchronized(customFactoryIds) {
            for (id in customFactoryIds) {
                GoogleMobileAdsPlugin.unregisterNativeAdFactory(engine, id)
            }
            customFactoryIds.clear()

            for (factoryData in factories) {
                val factoryId = factoryData["factoryId"] as? String ?: continue
                GoogleMobileAdsPlugin.registerNativeAdFactory(
                    engine,
                    factoryId,
                    DynamicNativeAdFactory(ctx, factoryId)
                )
                customFactoryIds.add(factoryId)
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        synchronized(customFactoryIds) {
            for (id in customFactoryIds) {
                GoogleMobileAdsPlugin.unregisterNativeAdFactory(binding.flutterEngine, id)
            }
            customFactoryIds.clear()
        }

        channel?.setMethodCallHandler(null)
        channel = null
        staticChannel = null
        context = null
        pluginBinding = null
    }
}