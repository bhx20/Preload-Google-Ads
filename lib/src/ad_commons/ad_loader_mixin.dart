import '../ad_internal.dart';

/// A mixin to provide shared ad loading and lifecycle logic.
mixin AdLoaderMixin {
  /// Flag to track if the ad is currently loaded.
  bool isAdLoaded = false;

  /// Counter to track when the ad should be shown.
  int counter = 0;

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
    isAdLoaded = false;
  }

  /// Resets the ad state.
  void reset() {
    isAdLoaded = false;
    counter = 0;
  }
}
