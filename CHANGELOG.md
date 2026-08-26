## v1.0.7

- **Rewarded Interstitial Format Integration**:
  - Added full preloading and management support for **Rewarded Interstitial Ads** via `RewardInterAd` and `showRewardedInterstitialAd(...)`.
- **Collapsible & Standard Banner Modularization**:
  - Introduced `ShowCollapsibleBannerAd` for dedicated, dynamic collapsible banner ad display.
  - Added strongly-typed `CollapsibleBannerPosition` enum (`bottom` and `top`) replacing string literals.
  - Added `FittedBox(fit: BoxFit.contain)` responsive layout container to scale standard and collapsible banners seamlessly inside parent constraints.
- **Native Customizer Live Updates**:
  - Fixed native ad disappearance on dynamic color selections by updating MethodChannel state without clearing active loaded ad instances.
  - Expanded `CustomNativeADStyle` to support title, body, button, tag foreground/background colors, radius sliders, and button gradient tokens.
  - Added optional `Key? key` parameter to `showNativeAd(...)` and `showCollapsibleBannerAd(...)` for instant subtree key identity updates.
- **Comprehensive Unit Testing Suite**:
  - Modularized unit tests into dedicated files under `test/`: `ad_commons_test.dart`, `banner_ad_test.dart`, `native_ad_test.dart`, `inter_ad_test.dart`, `rewarded_ad_test.dart`, `app_open_ad_test.dart`, and `preload_google_ads_test.dart`.
- **Showcase Example App Redesign**:
  - Streamlined navigation into clean top-level tabs: **Dashboard**, **Customizer**, **Native Feed**, **Banner Ads**, and **Ad Lab**.
  - Updated branding logo and app launcher icons across Android and iOS assets.

## v1.0.6

- Added Swift Package Manager (SPM) support for iOS.
- Improved package description for better pub.dev compliance and score.

## v1.0.5

- Added iOS implementation boilerplate and native ad factory foundations.
- General codebase cleanup and removal of unused constants.

## v1.0.4

- Modernized Android build configuration (Java 11, Kotlin 2.1.0, and latest AGP).
- Redesigned `README.md` for better clarity, aesthetics, and professional presentation.
- Organized project assets by moving demo GIFs to a dedicated `docs/assets` directory.

## v1.0.3

- Updated package version to `v1.0.3`.
- Fixed minor typos and wording issues across the codebase and documentation.
- No API changes or breaking behavior.
- Internal cleanups only; existing integrations continue to work without modification.

## v1.0.0

- Promoted to stable release from pre-release versions after multiple improvements and iterations.
- Consolidated and optimized internal architecture for long-term maintainability and scalability.
- Finalized and validated all major features:
    - Real-time ad status tracking across all supported ad types.
    - Stable and consistent ad lifecycle event handling (load, show, fail, click).
    - Custom native ad layout support with enhanced UI integration.
    - Full ad preloading for Open App, Interstitial, Rewarded, Native (Small/Medium), and Banner
      formats.
- Clean Dart analysis and fully production-ready for Android.
- Updated README.md with comprehensive usage samples and support documentation.
- Addressed minor bugs and preview issues from previous versions.
- Ready for production usage as v1.0.0 milestone.
