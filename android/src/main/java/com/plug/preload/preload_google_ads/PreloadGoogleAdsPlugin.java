package com.plug.preload.preload_google_ads;

import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;

public class PreloadGoogleAdsPlugin implements FlutterPlugin {
    private Context context;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext();

        // Register the native ad factories here
        GoogleMobileAdsPlugin.registerNativeAdFactory(
                flutterPluginBinding.getFlutterEngine(),
                "listTile",
                new android.src.main.java.com.plug.preload.preload_google_ads.NativeAdFactorySmall(context)
        );
        GoogleMobileAdsPlugin.registerNativeAdFactory(
                flutterPluginBinding.getFlutterEngine(),
                "listTileMedium",
                new android.src.main.java.com.plug.preload.preload_google_ads.NativeAdFactoryMedium(context)
        );
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        // Unregister the native ad factories
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(binding.getFlutterEngine(), "listTile");
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(binding.getFlutterEngine(), "listTileMedium");
    }
}
