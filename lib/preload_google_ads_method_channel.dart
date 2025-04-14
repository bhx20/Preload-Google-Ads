import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'preload_google_ads_platform_interface.dart';

/// An implementation of [PreloadGoogleAdsPlatform] that uses method channels.
class MethodChannelPreloadGoogleAds extends PreloadGoogleAdsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('preload_google_ads');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
