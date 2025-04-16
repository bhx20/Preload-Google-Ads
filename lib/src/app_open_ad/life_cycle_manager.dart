import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../preload_google_ads.dart';

class LifeCycleManager {
  static final LifeCycleManager instance = LifeCycleManager._internal();

  factory LifeCycleManager() {
    return instance;
  }

  LifeCycleManager._internal();

  late AppOpenAdManager appOpenAdManager;
  late AppLifecycleReactor _appLifecycleReactor;

  Future<void> getOpenAppAdvertise() async {
    appOpenAdManager = AppOpenAdManager()..loadAd();
    _appLifecycleReactor = AppLifecycleReactor(
      appOpenAdManager: appOpenAdManager,
    );
    _appLifecycleReactor.listenToAppStateChanges();
  }
}

class AppLifecycleReactor {
  final AppOpenAdManager appOpenAdManager;
  AppLifecycleReactor({required this.appOpenAdManager});

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.forEach(
      (state) => _onAppStateChanged(state),
    );
  }

  void _onAppStateChanged(AppState appState) {
    AppLogger.log('New AppState state: $appState');
    if (PreloadGoogleAds.instance.initialData.showOpenApp == true &&
        PreloadGoogleAds.instance.initialData.showAd == true) {
      if (appState == AppState.foreground) {
        appOpenAdManager.showAdIfAvailable();
      }
    }
  }
}
