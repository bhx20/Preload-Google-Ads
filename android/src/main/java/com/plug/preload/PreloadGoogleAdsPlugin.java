package com.plug.preload;

import android.content.Context;

import androidx.annotation.NonNull;

import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin;

public class PreloadGoogleAdsPlugin implements FlutterPlugin {
    private Context context;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext();

        MethodChannel colorChannel = new MethodChannel(
                flutterPluginBinding.getBinaryMessenger(),
                "com.plug.preload/adButtonStyle"
        );

        colorChannel.setMethodCallHandler((call, result) -> {
            if (call.method.equals("setAdStyle")) {
                if (call.arguments instanceof Map) {
                    Map<String, Object> receivedStyleMap = (Map<String, Object>) call.arguments;

                    // Unregister old factories if they exist (safe re-registering)
                    GoogleMobileAdsPlugin.unregisterNativeAdFactory(
                            flutterPluginBinding.getFlutterEngine(), "listTileMedium"
                    );
                    GoogleMobileAdsPlugin.unregisterNativeAdFactory(
                            flutterPluginBinding.getFlutterEngine(), "listTile"
                    );

                    // Register updated factories with new style
                    GoogleMobileAdsPlugin.registerNativeAdFactory(
                            flutterPluginBinding.getFlutterEngine(),
                            "listTileMedium",
                            new android.src.main.java.com.plug.preload.NativeAdFactoryMedium(context, receivedStyleMap)
                    );

                    GoogleMobileAdsPlugin.registerNativeAdFactory(
                            flutterPluginBinding.getFlutterEngine(),
                            "listTile",
                            new android.src.main.java.com.plug.preload.NativeAdFactorySmall(context, receivedStyleMap)
                    );

                    result.success(null);
                } else {
                    result.error("INVALID_ARGUMENT", "Expected a style map", null);
                }
            } else {
                result.notImplemented();
            }
        });
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(binding.getFlutterEngine(), "listTile");
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(binding.getFlutterEngine(), "listTileMedium");
    }
}
