import '../ad_internal.dart';

/// The channel name for native ad style communication.
const nativeChannel = 'com.plug.preload/adButtonStyle';

/// The method name for setting ad style data.
const nativeMethod = 'setAdStyle';


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

  /// Native Video Ad Unit ID
  static String get nativeVideo => _getId(
        androidId: 'ca-app-pub-3940256099942544/1044960115',
        iosId: 'ca-app-pub-3940256099942544/2521693316',
      );

  /// App Open Ad Unit ID
  static String get appOpen => _getId(
        androidId: 'ca-app-pub-3940256099942544/9257395921',
        iosId: 'ca-app-pub-3940256099942544/5575463023',
      );

  /// Helper method to select platform-specific Ad ID
  static String _getId({required String androidId, required String iosId}) {
    if (Platform.isIOS) return iosId;
    return androidId;
  }
}

/// The type of layout for native ads.
enum AdLayout {
  /// Use Flutter-based layout for native ads.
  flutterLayout,

  /// Use native platform-based layout for native ads.
  nativeLayout
}

