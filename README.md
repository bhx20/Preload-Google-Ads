# preload_google_ads

[![pub package](https://img.shields.io/pub/v/preload_google_ads.svg?color=blue)](https://pub.dev/packages/preload_google_ads)
[![Publisher](https://img.shields.io/pub/publisher/preload_google_ads.svg?color=blue)](https://pub.dev/packages/preload_google_ads)

This package preloads Google Ads in the background during app startup, ensuring quick and seamless display. It supports interstitial, rewarded, native, banners, and app open ads, with dynamic ad management, click counters, test ad ID fallback, and native layout customization.

- Preloads ads for fast and seamless display
- Supports interstitial, rewarded, banner, native(small-layout,medium-layout), and app open ads
- Automatic ad reloading and click counter logic
- Falls back to test ad IDs when custom IDs are not provided
- Native layout customization with Kotlin or Flutter views

## Preview

Below are some previews showing ad preloading in action:

<div style="display: flex; gap: 12px;">
  <img src="https://raw.githubusercontent.com/bhx20/Preload-Google-Ads/main/1.gif" alt="Demo 1" width="20%" />
  <img src="https://raw.githubusercontent.com/bhx20/Preload-Google-Ads/main/2.gif" alt="Demo 2" width="20%" />
</div>




## Usage

To get started, initialize the plugin at the top of your `main()` method before running the app:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize the Preload Google Ads
  PreloadGoogleAds.instance.initialize(
      adConfigData: AdConfigData(
          adIDs: AdIDS(
            appOpenId: AdTestIds.appOpen,
            bannerId: AdTestIds.banner,
            nativeId: AdTestIds.native,
            interstitialId: AdTestIds.interstitial,
            rewardedId: AdTestIds.rewarded,
          )));

  runApp(const MyApp());
}
```
> This will load the ads during app initialization and then manage the ad loading process in the background automatically.  
> Make sure to replace the test Ad IDs with your actual live AdMob IDs before releasing to production.

### Custom Config Data

You can easily customize the ad behavior using `AdConfigData`. This allows you to control ad visibility through flags and set how often different ad types should appear using counters—all tailored to your app's requirements.

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize the Preload Google Ads
  PreloadGoogleAds.instance.initialize(
    adConfigData: AdConfigData(
      adCounter: AdCounter(
        interstitialCounter: 0,
        nativeCounter: 0,
        rewardedCounter: 0,
      ),
      adFlag: AdFlag(
        showSplashAd: false,
        showAd: true,
        showBanner: true,
        showInterstitial: true,
        showNative: true,
        showOpenApp: true,
        showRewarded: true,
      ),
    ),
  );

  runApp(const MyApp());
}

```

### Custom Native Ad Layout

You can fully customize the appearance of native ads using the `nativeADLayout` parameter inside `AdConfigData`. This allows you to define padding, margin, border styles, and switch between custom Kotlin-based native ads and default Flutter layouts. Additionally, you can custom the button color, title color, and body color, ad background color to match your app’s design.

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize the Preload Google Ads with custom native ad layout
  PreloadGoogleAds.instance.initialize(
    adConfig: AdConfigData(
      nativeADLayout: NativeADLayout(
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(5),
        ),
        adLayout: AdLayout.nativeLayout,
        customNativeADStyle: CustomNativeADStyle(),
        flutterNativeADStyle: FlutterNativeADStyle(),
      ),
    ),
  );

  runApp(const MyApp());
}
```

### Splash Ad Callback

If you wish to show an open app ad during the loading time of the app, you can use the splash ad feature. Set the `showSplashAd` flag to `true` during initialization, and use the `setSplashAdCallback` function to handle navigation after the splash ad completes.

You can replace the default app navigation in the callback with your custom navigation logic.

```dart
PreloadGoogleAds.instance.setSplashAdCallback((ad, error) {
  debugPrint("Ad callback triggered, ${ad?.adUnitId}");

  // Replace this navigation logic with your desired navigation after the splash ad completes
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const HomeView()),
  );
});
```
### Show Ads Counter

The **Ads Counter** is a built-in diagnostic tool that helps you monitor the status of different ad formats in real-time. It displays statistics for the following ad types:  
**Interstitial** | **Rewarded** | **Banner** | **Small Native** | **Medium Native** | **Open App**

For each ad type, the counter displays:  
**Load status** | **Show status** | **Failed to load status**

You can enable the Ads Counter by calling:

```dart
PreloadGoogleAds.instance.showAdCounter(showCounter: true);
```

### Show Native Ads

To display a native ad, use the method below. It returns a widget, so you can use it directly in your widget tree. You can choose between `medium` and `small` ad types:


```dart
// Show a medium-sized native ad
PreloadGoogleAds.instance.showNativeAd(nativeADType: NativeADType.medium);

// Show a small-sized native ad
PreloadGoogleAds.instance.showNativeAd(nativeADType: NativeADType.small);
```

> You can customize the native ad layout.  
> To do this, set the configuration while initializing the ads.  
> You can also control the ad display frequency using a click counter. For example, setting the counter to `2` will display the ad after every 2 user clicks or actions.


### Show Banner Ad

To display a banner ad, use the method below. It returns a widget, so you can use it directly in your widget tree:

```dart
PreloadGoogleAds.instance.showBannerAd();

```
### Show Interstitial Ad

To show an interstitial ad, use the method below. It handles the loading and provides a callback with success or failure:

```dart
PreloadGoogleAds.instance.showInterstitialAd(
  callBack: (ad, error) {
    if (ad != null) {
      debugPrint("Inter AD loaded successfully!");
      debugPrint(ad.adUnitId);
    } else {
      debugPrint("Inter Ad failed to load: ${error?.message}");
    }
  },
);
```
> If you want to show an interstitial ad during a navigation flow, simply call this function before navigating and place your navigation logic inside the `callBack`.  
> The callback handles both success and failure.  
> You can also control the ad display frequency using a click counter. For example, setting the counter to `2` will display the ad after every 2 user clicks or actions.

### Show Rewarded Ad

To display a rewarded ad, use the method below. It provides both a callback for ad loading and an additional reward callback to handle rewards earned by the user:

```dart
PreloadGoogleAds.instance.showRewardedAd(
  callBack: (ad, error) {
    if (ad != null) {
      debugPrint("Ad loaded successfully!");
    } else {
      debugPrint("Ad failed to load: ${error?.message}");
    }
  },
  onReward: (ad, reward) {
    debugPrint("User earned reward: ${reward.amount} ${reward.type}");
  },
);
```
> To show the rewarded ad after a specific number of user clicks, you can set a click counter (e.g., 2). The rewarded ad will be displayed after the user clicks the specified number of times. You can manage this using the `callBack`, which will handle both the ad loading and the reward logic once the ad has been shown. The `onReward` callback will be triggered when the user earns their reward after watching the ad.

### Show Open App Ad

By default, the **Open App Ad** will display when the app transitions from background to foreground. If you don't want the ad to show during this transition, you can disable it by setting the flag to `false`. You can also manually show the open app ad at any time using the `PreloadGoogleAds.instance.showOpenApp()` method.

```dart
PreloadGoogleAds.instance.showOpenApp();
```
---

## Support & Contributions

We welcome contributions! Feel free to open issues, submit pull requests, or suggest improvements.

If this package helps you, consider starring it on [pub.dev](https://pub.dev/packages/preload_google_ads) to show your support.



## License

This project is licensed under the Apache License 2.0.  
See the [LICENSE](https://github.com/bhx20/Preload-Google-Ads/blob/main/LICENSE) file for details.



## Contact

For support or business inquiries, please reach out at:  
**Email**: sanketkalathiya201@gmail.com  
**GitHub**: [https://github.com/bhx20](https://github.com/bhx20/)

<span style="color:#4285F4">|</span> Built with performance and flexibility in mind — preload your ads and boost user experience with minimal effort.
