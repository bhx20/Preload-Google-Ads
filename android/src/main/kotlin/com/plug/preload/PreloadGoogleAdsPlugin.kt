package com.plug.preload

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

/**
 * PreloadGoogleAdsPlugin
 *
 * This plugin handles the registration of native ad factories and provides
 * a method channel for dynamic ad styling from the Flutter side.
 */
class PreloadGoogleAdsPlugin : FlutterPlugin {
    private var context: Context? = null
    private var channel: MethodChannel? = null

    companion object {
        private const val TAG = "PreloadGoogleAdsPlugin"
        private const val CHANNEL_NAME = "com.plug.preload/adButtonStyle"
        private const val METHOD_SET_STYLE = "setAdStyle"
        
        private const val FACTORY_ID_MEDIUM = "medium_native"
        private const val FACTORY_ID_SMALL = "small_native"
    }

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        context = binding.applicationContext

        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    METHOD_SET_STYLE -> {
                        val arguments = call.arguments
                        if (arguments is Map<*, *>) {
                            @Suppress("UNCHECKED_CAST")
                            val receivedStyleMap = arguments as Map<String, Any>
                            
                            updateNativeAdFactories(binding, receivedStyleMap)
                            result.success(null)
                        } else {
                            result.error("INVALID_ARGUMENT", "Expected a style map", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        }
        
        Log.d(TAG, "Plugin attached to engine")
    }

    private fun updateNativeAdFactories(binding: FlutterPluginBinding, styleMap: Map<String, Any>) {
        val engine = binding.flutterEngine
        val ctx = context ?: return

        // Safely unregister old factories
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(engine, FACTORY_ID_MEDIUM)
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(engine, FACTORY_ID_SMALL)

        // Register new factories with updated styles
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            engine, FACTORY_ID_MEDIUM, NativeAdFactoryMedium(ctx, styleMap)
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            engine, FACTORY_ID_SMALL, NativeAdFactorySmall(ctx, styleMap)
        )

        Log.d(TAG, "Native ad factories updated with new style map")
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        // Clean up factories to prevent memory leaks
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(binding.flutterEngine, FACTORY_ID_MEDIUM)
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(binding.flutterEngine, FACTORY_ID_SMALL)
        
        channel?.setMethodCallHandler(null)
        channel = null
        context = null
        
        Log.d(TAG, "Plugin detached from engine and factories cleaned up")
    }
}
