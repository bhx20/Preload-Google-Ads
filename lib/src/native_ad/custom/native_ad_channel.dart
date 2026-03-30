import 'package:flutter/services.dart';

/// Centralized MethodChannel abstraction for the custom native ad system.
///
/// All method names, argument keys, and response parsing are defined here
/// to ensure consistency between Flutter and native sides.
class NativeAdChannel {
  NativeAdChannel._();

  // ---------------------------------------------------------------------------
  // Channel name — intentionally separate from the existing adButtonStyle
  // channel so the two systems operate independently.
  // ---------------------------------------------------------------------------
  /// The channel name for the custom native ad system.
  static const String channelName = 'com.plug.preload/customNativeAd';

  /// Singleton channel instance shared by all custom native ad views.
  static const MethodChannel channel = MethodChannel(channelName);

  // ---------------------------------------------------------------------------
  // Flutter → Native method names
  // ---------------------------------------------------------------------------

  /// Tells native to load a new ad for the given viewId.
  static const String methodLoadAd = 'loadAd';

  /// Tells native to dispose the ad and its resources for the given viewId.
  static const String methodDisposeAd = 'disposeAd';

  /// Sends Flutter-measured click-area rects to native for SDK registration.
  static const String methodRegisterClickAreas = 'registerClickAreas';

  // ---------------------------------------------------------------------------
  // Native → Flutter method names (callbacks)
  // ---------------------------------------------------------------------------

  /// Native extracted ad assets and sends them to Flutter.
  static const String methodOnAdAssetsReady = 'onAdAssetsReady';

  /// Native reports that the ad finished loading (distinct from assets ready).
  static const String methodOnAdLoaded = 'onAdLoaded';

  /// Native reports that the ad failed to load.
  static const String methodOnAdFailed = 'onAdFailed';

  /// Native reports that the ad was clicked.
  static const String methodOnAdClicked = 'onAdClicked';

  /// Native reports an impression was recorded.
  static const String methodOnAdImpression = 'onAdImpression';

  /// Native reports the ad opened a full-screen overlay.
  static const String methodOnAdOpened = 'onAdOpened';

  /// Native reports the full-screen overlay was closed.
  static const String methodOnAdClosed = 'onAdClosed';

  // ---------------------------------------------------------------------------
  // Argument keys — used in Maps sent across the channel
  // ---------------------------------------------------------------------------

  /// Unique identifier for a specific ad instance (int, from PlatformView).
  static const String argViewId = 'viewId';

  /// Ad unit ID string (e.g. 'ca-app-pub-xxx/yyy').
  static const String argAdUnitId = 'adUnitId';

  /// Requested ad size category (custom).
  static const String argSize = 'size';

  /// Map of slot-name → Rect (as {left, top, width, height} in physical px).
  static const String argSlots = 'slots';

  /// Error code string from native.
  static const String argErrorCode = 'errorCode';

  /// Human-readable error message from native.
  static const String argErrorMessage = 'errorMessage';

  // ---------------------------------------------------------------------------
  // Asset keys — fields inside the onAdAssetsReady payload
  // ---------------------------------------------------------------------------
  /// The headline asset key.
  static const String assetHeadline = 'headline';

  /// The body asset key.
  static const String assetBody = 'body';

  /// The call to action asset key.
  static const String assetCallToAction = 'callToAction';

  /// The advertiser asset key.
  static const String assetAdvertiser = 'advertiser';

  /// The store asset key.
  static const String assetStore = 'store';

  /// The price asset key.
  static const String assetPrice = 'price';

  /// The rating asset key.
  static const String assetRating = 'rating';

  /// The icon bytes asset key.
  static const String assetIconBytes = 'iconBytes';

  /// The images asset key.
  static const String assetImages = 'images';

  /// The hasVideo asset key.
  static const String assetHasVideo = 'hasVideo';

  /// The duration asset key.
  static const String assetDuration = 'duration';

  /// The aspect ratio asset key.
  static const String assetAspectRatio = 'aspectRatio';

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Converts a Flutter logical [Rect] to a map of physical pixel values
  /// by multiplying with [devicePixelRatio].
  ///
  /// Native platforms work in physical pixels; Flutter works in logical pixels.
  /// This conversion is essential for accurate click-area registration.
  static Map<String, double> rectToPhysicalMap(
    Rect rect,
    double devicePixelRatio,
  ) {
    return {
      'left': rect.left * devicePixelRatio,
      'top': rect.top * devicePixelRatio,
      'width': rect.width * devicePixelRatio,
      'height': rect.height * devicePixelRatio,
    };
  }
}
