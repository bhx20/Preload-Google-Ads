import '../../preload_google_ads.dart';

/// Manages the lifecycle of the app's ads, especially the App Open Ads.
class LifeCycleManager {
  /// Singleton instance of LifeCycleManager.
  static final LifeCycleManager instance = LifeCycleManager._internal();

  /// Factory constructor that returns the singleton instance of LifeCycleManager.
  factory LifeCycleManager() {
    return instance;
  }

  /// Private constructor to prevent external instantiation.
  LifeCycleManager._internal();

  /// Instance of AppOpenAdManager to manage app open ads.
  late AppOpenAdManager appOpenAdManager;

  /// Instance of AppLifecycleReactor to listen for app state changes.
  late AppLifecycleReactor _appLifecycleReactor;

  /// Initializes the app open ad manager and starts listening to app state changes.
  Future<void> getOpenAppAdvertise() async {
    // Load the ad and prepare the lifecycle reactor for app state changes.
    appOpenAdManager = AppOpenAdManager()..loadAd();

    // Create an instance of AppLifecycleReactor and pass the appOpenAdManager to it.
    _appLifecycleReactor = AppLifecycleReactor(
      appOpenAdManager: appOpenAdManager,
    );

    // Start listening to app state changes.
    _appLifecycleReactor.listenToAppStateChanges();
  }
}

/// Reacts to app lifecycle changes and triggers the display of ads based on app state.
class AppLifecycleReactor {
  /// Instance of AppOpenAdManager to show app open ads.
  final AppOpenAdManager appOpenAdManager;

  /// Constructor that requires an instance of AppOpenAdManager.
  AppLifecycleReactor({required this.appOpenAdManager});

  /// Starts listening for app state changes and reacts accordingly.
  void listenToAppStateChanges() {
    /// Begin listening to the app's state changes.
    AppStateEventNotifier.startListening();

    /// For each state change, call _onAppStateChanged to react to it.
    AppStateEventNotifier.appStateStream.forEach(
      (state) => _onAppStateChanged(state),
    );
  }

  /// Handles changes in the app's state (e.g., when the app moves to the foreground).
  /// If appropriate, it triggers the app open ad to be shown.
  void _onAppStateChanged(AppState appState) {
    /// Log the new app state for debugging purposes.
    AppLogger.log('New AppState state: $appState');

    /// Check if the app should show an open app ad.
    if (shouldShowOpenAppAd) {
      /// If the app is in the foreground, show the app open ad.
      if (appState == AppState.foreground) {
        appOpenAdManager.showAdIfAvailable();
      }
    }
  }
}
