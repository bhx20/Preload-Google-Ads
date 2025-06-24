import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'preload_google_ads_method_channel.dart';

abstract class PreloadGoogleAdsPlatform extends PlatformInterface {
  /// Constructs a PreloadGoogleAdsPlatform.
  PreloadGoogleAdsPlatform() : super(token: _token);

  static final Object _token = Object();

  static PreloadGoogleAdsPlatform _instance = MethodChannelPreloadGoogleAds();

  /// The default instance of [PreloadGoogleAdsPlatform] to use.
  ///
  /// Defaults to [MethodChannelPreloadGoogleAds].
  static PreloadGoogleAdsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PreloadGoogleAdsPlatform] when
  /// they register themselves.
  static set instance(PreloadGoogleAdsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
