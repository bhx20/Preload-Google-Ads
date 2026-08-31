import '../ad_internal.dart';

/// Represents the current lifecycle state of an ad loader.
enum AdLoadState {
  /// Ad has not been requested or has been reset.
  initial,

  /// Ad request is currently in flight.
  loading,

  /// Ad is successfully preloaded and ready to show.
  ready,

  /// Ad failed to load.
  failed,

  /// Ad is currently being displayed on screen.
  showing,
}

/// Base contract and unified handler for all ad format loaders in the package.
abstract class BaseAdLoader with AdLoaderMixin {
  /// Loads the target ad format asynchronously.
  void load();

  /// Checks whether the ad format is enabled in configuration and can be loaded/shown.
  bool get isEnabled;

  /// Human readable label for logging.
  String get adLabel;

  /// Maximum duration allowed between loading and showing an ad (AdMob 4-hour rule).
  final Duration maxCacheDuration = const Duration(hours: 4);

  /// Timestamp when the ad was successfully loaded into memory.
  DateTime? loadTime;

  Timer? _reloadTimer;

  /// Checks if the cached ad has passed the max cache duration.
  bool get isExpired {
    if (loadTime == null) return false;
    return DateTime.now().subtract(maxCacheDuration).isAfter(loadTime!);
  }

  /// Cancels any scheduled background reload timer to prevent memory leaks.
  void cancelReloadTimer() {
    _reloadTimer?.cancel();
    _reloadTimer = null;
  }

  /// Schedules a background load task safely.
  void scheduleReload(Duration duration, VoidCallback callback) {
    cancelReloadTimer();
    _reloadTimer = Timer(duration, () {
      _reloadTimer = null;
      callback();
    });
  }

  /// Shared helper to determine if loading can proceed.
  bool prepareLoad() {
    if (!isEnabled) {
      AppLogger.log("$adLabel ads are disabled.");
      return false;
    }
    if (isLoading || isShowing) {
      AppLogger.log("$adLabel is already ${state.name}. Skipping load request.");
      return false;
    }
    state = AdLoadState.loading;
    return true;
  }

  /// Handles successful load events across all ad types.
  void handleLoadSuccess() {
    AppLogger.log("$adLabel loaded successfully.");
    loadTime = DateTime.now();
    state = AdLoadState.ready;
    retryAttempts = maxRetries;
  }

  /// Centralized retry handling with exponential backoff strategy when ad fails to load.
  void handleFailureAndRetry(dynamic error, {VoidCallback? onRetry}) {
    handleLoadError(adLabel, error);
    loadTime = null;
    if (retryAttempts > 1) {
      retryAttempts--;
      // Exponential backoff: 2s, 4s, 8s delay before retrying
      final backoffSeconds = (maxRetries - retryAttempts) * 2;
      AppLogger.log(
        "Retrying $adLabel load in $backoffSeconds seconds (Remaining attempts: $retryAttempts)",
      );
      scheduleReload(Duration(seconds: backoffSeconds), () {
        if (onRetry != null) {
          onRetry();
        } else {
          load();
        }
      });
    } else {
      retryAttempts = maxRetries;
    }
  }

  /// Centralized helper to evaluate showing condition against counters.
  bool canShowAd(int requiredLimit) {
    if (!isEnabled) return false;
    if (isAdLoaded && isLimitReached(requiredLimit)) {
      return true;
    }
    incrementCounter();
    if (!isAdLoaded && state != AdLoadState.loading) {
      load();
    }
    return false;
  }

  /// Resets state and disposes resources. Subclasses should override and call super.reset().
  @override
  void reset() {
    cancelReloadTimer();
    super.reset();
  }
}

/// A mixin to provide next-level ad loading and lifecycle state management.
mixin AdLoaderMixin {
  /// Current state of the ad loader.
  AdLoadState state = AdLoadState.initial;

  /// Counter to track when the ad should be shown.
  int counter = 0;

  /// Max load retries allowed on failure.
  int maxRetries = 3;

  /// Current retry attempt remaining.
  int retryAttempts = 3;

  /// Convenient boolean getter for loaded status.
  bool get isAdLoaded => state == AdLoadState.ready;

  /// Convenient boolean getter for loading status.
  bool get isLoading => state == AdLoadState.loading;

  /// Convenient boolean getter for showing status.
  bool get isShowing => state == AdLoadState.showing;

  /// Convenient boolean getter for failed status.
  bool get isFailed => state == AdLoadState.failed;

  /// Legacy reloadAdCount alias for retryAttempts.
  int get reloadAdCount => retryAttempts;

  /// Legacy setter compatibility
  set isAdLoaded(bool value) {
    if (value) {
      state = AdLoadState.ready;
    } else if (state == AdLoadState.ready) {
      state = AdLoadState.initial;
    }
  }

  /// Resets the counter to zero.
  void resetCounter() {
    counter = 0;
  }

  /// Increments the counter.
  void incrementCounter() {
    counter++;
  }

  /// Checks if the counter has reached the required limit.
  bool isLimitReached(int limit) {
    return counter >= limit;
  }

  /// Shared error handling and logging for ad loading.
  void handleLoadError(String adType, dynamic error) {
    AppLogger.error("Failed to load $adType: $error");
    state = AdLoadState.failed;
  }

  /// Resets the ad lifecycle state cleanly.
  void reset() {
    state = AdLoadState.initial;
    counter = 0;
    retryAttempts = maxRetries;
  }
}
