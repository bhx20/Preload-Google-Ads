<p align="center">
  <img src="https://raw.githubusercontent.com/bhx20/Preload-Google-Ads/main/docs/assets/Preload%20Google%20Ad%20Logo.png" alt="Preload Google Ads Logo" width="300" />
</p>

<p align="center">
  <a href="https://pub.dev/packages/preload_google_ads"><img src="https://img.shields.io/pub/v/preload_google_ads.svg?color=blue" alt="pub package"></a>
  <a href="https://pub.dev/packages/preload_google_ads"><img src="https://img.shields.io/pub/publisher/preload_google_ads.svg?color=blue" alt="Publisher"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"></a>
</p>

---

A high-performance Flutter plugin for **background preloading** of Google Mobile Ads (AdMob). Deliver a seamless, zero-latency experience by fetching ads before your users even need them.

---

## Key Features

- **Zero Latency**: Preload ads during app startup for immediate display.
- **All Formats Supported**: App Open, Interstitial, Rewarded, Native (Small/Medium), and Banner.
- **Auto-Reloading**: Automatically fetches fresh ads after display or failure.
- **Click Counter Logic**: Customizable frequency control (e.g., show every 3rd click).
- **Deep Customization**: Style native ads via Kotlin (Android) or Flutter views.
- **Developer Friendly**: Built-in Ad Counter for real-time tracking and debugging.
- **Fallback Ready**: Defaults to test ad IDs for safe and easy development.

---

## Preview

Below are some previews showing ad preloading in action. Notice the instant display!

<div style="display: flex; gap: 12px; justify-content: center; flex-wrap: wrap;">
  <img src="https://raw.githubusercontent.com/bhx20/Preload-Google-Ads/main/docs/assets/1.gif" alt="Demo 1" width="22%" />
  <img src="https://raw.githubusercontent.com/bhx20/Preload-Google-Ads/main/docs/assets/2.gif" alt="Demo 2" width="22%" />
  <img src="https://raw.githubusercontent.com/bhx20/Preload-Google-Ads/main/docs/assets/3.gif" alt="Demo 3" width="22%" />
  <img src="https://raw.githubusercontent.com/bhx20/Preload-Google-Ads/main/docs/assets/4.gif" alt="Demo 4" width="22%" />
</div>

---

## Getting Started

### 1. Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  preload_google_ads: ^1.0.7
```

Or run:
```bash
flutter pub add preload_google_ads
```

---

## Basic Usage

Initialize the plugin in your `main()` function. This kicks off the background preloading immediately.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize and start preloading
  await PreloadGoogleAds.instance.initialize(
    adConfigData: AdConfigData(
      adIDs: AdIDS(
        appOpenId: AdTestIds.appOpen,
        bannerId: AdTestIds.banner,
        nativeId: AdTestIds.native,
        interstitialId: AdTestIds.interstitial,
        rewardedId: AdTestIds.rewarded,
        rewardedInterstitialId: AdTestIds.rewardedInterstitial,
      ),
    ),
  );

  runApp(const MyApp());
}
```

---

## Advanced Configuration

### Click Counters & AD Flags
Control specifically which ads to show and how frequently they appear.

```dart
PreloadGoogleAds.instance.initialize(
  adConfigData: AdConfigData(
    adCounter: AdCounter(
      interstitialCounter: 2,        // Show every 2 clicks
      nativeCounter: 0,              // Show every time
      rewardedCounter: 1,            // Show every click
      rewardedInterCounter: 1,       // Show every click
    ),
    adFlag: AdFlag(
      showAd: true,
      showBanner: true,
      showInterstitial: true,
      showNative: true,
      showOpenApp: true,
      showRewarded: true,
      showRewardedInter: true,
      showSplashAd: false,
    ),
  ),
);
```

### Native Ad Custom Styling
Customize the appearance of native ads with light and dark mode tokens.

```dart
NativeADLayout(
  padding: const EdgeInsets.all(8),
  lightDecoration: BoxDecoration(
    color: Colors.white,
    border: Border.all(color: Colors.grey.shade300),
    borderRadius: BorderRadius.circular(12),
  ),
  darkDecoration: BoxDecoration(
    color: const Color(0xFF1E293B),
    border: Border.all(color: const Color(0xFF334155)),
    borderRadius: BorderRadius.circular(12),
  ),
  customNativeADStyle: CustomNativeADStyle(
    titleColor: Colors.black,
    bodyColor: Colors.grey.shade700,
    buttonBackground: Colors.blueAccent,
    buttonForeground: Colors.white,
    buttonRadius: 10,
    tagBackground: Colors.amber,
    tagForeground: Colors.black,
  ),
  darkCustomNativeADStyle: CustomNativeADStyle.dark(
    titleColor: Colors.white,
    bodyColor: Colors.grey.shade300,
    buttonBackground: Colors.indigoAccent,
    buttonForeground: Colors.white,
    buttonRadius: 10,
  ),
)
```

---

## Showing Ads

| Format | Method | Description |
| :--- | :--- | :--- |
| **Native** | `PreloadGoogleAds.instance.showNativeAd(key: ..., nativeADType: NativeADType.medium)` | Displays native ad with key identity & medium/small layout |
| **Standard Banner** | `PreloadGoogleAds.instance.showBannerAd()` | Displays standard 320x50 adaptive banner scaled with `FittedBox` |
| **Collapsible Banner** | `PreloadGoogleAds.instance.showCollapsibleBannerAd(collapsiblePosition: CollapsibleBannerPosition.bottom)` | Displays dynamic collapsible banner anchored to `bottom` or `top` |
| **Interstitial** | `PreloadGoogleAds.instance.showInterstitialAd(callBack: (ad, error) => ...)` | Shows full-screen interstitial ad |
| **Rewarded** | `PreloadGoogleAds.instance.showRewardedAd(callBack: ..., onReward: (ad, reward) => ...)` | Shows rewarded ad and grants reward item |
| **Rewarded Interstitial** | `PreloadGoogleAds.instance.showRewardedInterstitialAd(callBack: ..., onReward: (ad, reward) => ...)` | Shows rewarded interstitial ad and grants reward item |
| **App Open** | `PreloadGoogleAds.instance.showOpenApp()` | Shows app open ad |

> [!TIP]
> **Pro Tip**: To show an ad during navigation, place your navigation logic inside the `callBack`. This ensures the transition happens exactly when the ad is closed or fails to load.

### Splash Ad Callback
Show an app open ad immediately on splash and navigate when ready.

```dart
PreloadGoogleAds.instance.setSplashAdCallback((ad, error) {
  // Navigate to Home after splash ad completes
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeView()));
});
```

### Diagnostic Counter
Enable the built-in counter to track ad status in real-time during development.

```dart
PreloadGoogleAds.instance.showAdCounter(showCounter: true);
```

> [!IMPORTANT]
> **Ad IDs**: Always replace the test IDs with your production AdMob IDs before publishing. Using test IDs in production may result in no ads being served or policy violations.

---

## Support & Contributions

We welcome contributions!
- **Bugs**: Open an issue on GitHub.
- **Feature Request**: Open a discussion.
- **Starred**: If this package helps you, give it a ⭐ on [pub.dev](https://pub.dev/packages/preload_google_ads).

---

## License & Contact

- **License**: [MIT License](https://github.com/coddyNet/Preload-Google-Ads/blob/main/LICENSE)
- **Author**: CoddyNet Infotech
- **Email**: coddynet@gmail.com
- **GitHub**: [https://github.com/coddyNet](https://github.com/coddyNet)

---

<p align="center">
  <b>Built with passion for Flutter Developers seeking top-tier performance.</b>
</p>
