
import 'preload_google_ads_platform_interface.dart';

class PreloadGoogleAds {
  Future<String?> getPlatformVersion() {
    return PreloadGoogleAdsPlatform.instance.getPlatformVersion();
  }
}
