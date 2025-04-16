package com.plug.preload;

import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;

public class PreloadGoogleAdsPlugin implements FlutterPlugin {
    private Context context; /// Context to access app resources

    /**
     * Called when the plugin is attached to the Flutter engine.
     * Initializes the plugin by registering native ad factories.
     */
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext(); /// Get the application context

        /// Register the first native ad factory with a name "listTile" and associate it with the NativeAdFactorySmall class
        GoogleMobileAdsPlugin.registerNativeAdFactory(
                flutterPluginBinding.getFlutterEngine(),
                "listTile", /// Name of the native ad factory in Flutter
                new android.src.main.java.com.plug.preload.NativeAdFactorySmall(context) /// NativeAdFactory for small ad layout
        );

        /// Register the second native ad factory with a name "listTileMedium" and associate it with the NativeAdFactoryMedium class
        GoogleMobileAdsPlugin.registerNativeAdFactory(
                flutterPluginBinding.getFlutterEngine(),
                "listTileMedium", /// Name of the native ad factory in Flutter
                new android.src.main.java.com.plug.preload.NativeAdFactoryMedium(context) /// NativeAdFactory for medium ad layout
        );
    }

    /**
     * Called when the plugin is detached from the Flutter engine.
     * Unregisters the native ad factories to clean up resources.
     */
    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        /// Unregister the "listTile" native ad factory
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(binding.getFlutterEngine(), "listTile");

        /// Unregister the "listTileMedium" native ad factory
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(binding.getFlutterEngine(), "listTileMedium");
    }
}
