import 'dart:typed_data';
import 'package:flutter/widgets.dart';

/// Holds all ad asset strings and widget references extracted from the native ad.
///
/// This is passed to the developer's builder callback so they can use any of
/// these values in their fully custom Flutter UI.
class NativeAdData {
  /// The main headline text of the ad (required by SDK).
  final String? headline;

  /// The body / description text.
  final String? body;

  /// The call-to-action label (e.g. "Install", "Learn More").
  final String? callToAction;

  /// The advertiser / brand name.
  final String? advertiser;

  /// The app store name (e.g. "Google Play", "App Store").
  final String? store;

  /// The price string (e.g. "Free", "$1.99").
  final String? price;

  /// Star rating of the advertised app (0–5).
  final double? rating;

  /// Raw PNG bytes of the ad icon.
  final Uint8List? iconBytes;

  /// URLs of the ad's images (if any).
  final List<String> imageUrls;

  /// Whether the ad contains video content.
  final bool hasVideo;

  /// Duration of the video content in seconds (0 if no video).
  final double? duration;

  /// Aspect ratio of the media content (width / height).
  final double? aspectRatio;

  /// A platform-view widget that renders the native SDK MediaView.
  final Widget mediaView;

  /// A platform-view widget that renders the native SDK icon view.
  final Widget iconView;

  /// Callback that triggers the native CTA click action.
  final VoidCallback? onCTAPressed;

  /// GlobalKeys for each ad slot, used to measure screen positions.
  final Map<String, GlobalKey> slotKeys;

  /// Creates a [NativeAdData] instance.
  const NativeAdData({
    this.headline,
    this.body,
    this.callToAction,
    this.advertiser,
    this.store,
    this.price,
    this.rating,
    this.iconBytes,
    this.imageUrls = const [],
    this.hasVideo = false,
    this.duration,
    this.aspectRatio,
    required this.mediaView,
    required this.iconView,
    this.onCTAPressed,
    this.slotKeys = const {},
  });

  /// Convenience getter: true if an icon image is available.
  bool get hasIcon => iconBytes != null && iconBytes!.isNotEmpty;

  /// Convenience getter: builds a Flutter Image widget from iconBytes.
  Widget? get iconImage =>
      hasIcon ? Image.memory(iconBytes!, fit: BoxFit.cover) : null;
}
