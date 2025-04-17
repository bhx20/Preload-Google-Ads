import '../../preload_google_ads.dart';

const nativeChannel = 'com.plug.preload/adButtonStyle';
const nativeMethod = 'setAdStyle';
const factoryIdMediumNative = 'medium_native';
const factoryIdSmallNative = 'small_native';

///==============================================================================
///              **  AD Test ID Class  **
///==============================================================================
/// A utility class to manage Google AdMob Test Ad Unit IDs for both Android and iOS.
/// Easily extendable for production IDs later.
class AdTestIds {
  /// Banner Ad Unit ID
  static String get banner => _getId(
    androidId: 'ca-app-pub-3940256099942544/6300978111',
    iosId: 'ca-app-pub-3940256099942544/2934735716',
  );

  /// Interstitial Ad Unit ID
  static String get interstitial => _getId(
    androidId: 'ca-app-pub-3940256099942544/1033173712',
    iosId: 'ca-app-pub-3940256099942544/4411468910',
  );

  /// Rewarded Ad Unit ID
  static String get rewarded => _getId(
    androidId: 'ca-app-pub-3940256099942544/5224354917',
    iosId: 'ca-app-pub-3940256099942544/1712485313',
  );

  /// Rewarded Interstitial Ad Unit ID
  static String get rewardedInterstitial => _getId(
    androidId: 'ca-app-pub-3940256099942544/5354046379',
    iosId: 'ca-app-pub-3940256099942544/6978759866',
  );

  /// Native Advanced Ad Unit ID
  static String get native => _getId(
    androidId: 'ca-app-pub-3940256099942544/2247696110',
    iosId: 'ca-app-pub-3940256099942544/3986624511',
  );

  /// App Open Ad Unit ID
  static String get appOpen => _getId(
    androidId: 'ca-app-pub-3940256099942544/9257395921',
    iosId: 'ca-app-pub-3940256099942544/5662855259',
  );

  /// Helper method to select platform-specific Ad ID
  static String _getId({required String androidId, required String iosId}) {
    if (Platform.isAndroid) return androidId;
    if (Platform.isIOS) return iosId;
    throw UnsupportedError('Unsupported platform');
  }
}
