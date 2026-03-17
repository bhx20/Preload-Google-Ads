import '../ad_internal.dart';

/// A singleton class to manage loading and showing rewarded ads.
class RewardAd with AdLoaderMixin {
  /// Singleton instance of [RewardAd].
  static final RewardAd instance = RewardAd._internal();

  /// Factory constructor to provide access to the singleton [RewardAd].
  factory RewardAd() {
    return instance;
  }

  /// Private constructor for [RewardAd] singleton.
  RewardAd._internal();

  RewardedAd? _rewardedAd; // Stores the loaded rewarded ad.

  /// Loads a rewarded ad with the given unit ID and configuration.
  void load() {
    try {
      isAdLoaded = false;
      RewardedAd.load(
        adUnitId: unitIDRewarded, // ID for the rewarded ad unit.
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          // Called when the ad has successfully loaded.
          onAdLoaded: (ad) {
            AdStats.instance.rewardedLoad.value++; // Increment ad load count.
            AppLogger.log("Rewarded ad loaded.");
            _rewardedAd = ad;
            _rewardedAd!.setImmersiveMode(true); // Enable immersive mode.
            isAdLoaded = true;
          },
          // Called if the ad fails to load.
          onAdFailedToLoad: (LoadAdError error) {
            AdStats.instance.rewardedFailed
                .value++; // Increment ad load failure count.
            _rewardedAd = null;
            handleLoadError("Rewarded", error);
          },
        ),
      );
    } catch (error) {
      _rewardedAd?.dispose(); // Dispose ad if there's an error.
    }
  }

  /// Shows the rewarded ad if it is loaded and the conditions are met.
  void showRewarded({
    required Function({RewardedAd? ad, AdError? error}) callBack,
    required Function(AdWithoutView ad, RewardItem reward) onReward,
  }) {
    if (shouldShowRewardedAd) {
      // Check if rewarded ad should be shown.
      // Check if the ad is loaded and the counter has reached the limit.
      if (isAdLoaded &&
          _rewardedAd != null &&
          isLimitReached(getRewardedCounter)) {
        resetCounter(); // Reset the counter after showing the ad.

        _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
          // Called when the ad is dismissed.
          onAdDismissedFullScreenContent: (ad) {
            callBack(ad: ad); // Callback after ad is dismissed.
            ad.dispose();
            _rewardedAd = null;
            load(); // Reload ad after dismissal.
          },
          // Called when the ad is shown (impression).
          onAdImpression: (ad) {
            AdStats.instance.rewardedImp.value++; // Increment impression count.
          },
          // Called if the ad fails to show.
          onAdFailedToShowFullScreenContent: (ad, error) {
            callBack(ad: ad, error: error); // Callback on failure to show.
            AppLogger.error('$ad failed to show: $error');
            _rewardedAd = null;
            ad.dispose();
            load(); // Reload ad after failure.
          },
        );

        // Show the rewarded ad and handle the reward.
        _rewardedAd!.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
            onReward(ad, reward); // Handle the reward when the user earns it.
          },
        );
      } else {
        incrementCounter(); // Increment the counter if ad is not shown yet.
        callBack(); // Callback if the ad is not shown.
      }
    } else {
      callBack(); // Callback if ads shouldn't be shown.
    }
  }

  /// Resets the ad state and disposes of loaded ads.
  @override
  void reset() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    isAdLoaded = false;
  }
}
