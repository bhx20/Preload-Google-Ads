import '../../preload_google_ads.dart';

/// A singleton class to manage loading and showing rewarded ads.
class RewardAd {
  static final RewardAd instance = RewardAd._internal();

  factory RewardAd() {
    return instance;
  }

  RewardAd._internal();

  RewardedAd? _rewardedAd; // Stores the loaded rewarded ad.
  bool _isRewardedAdLoaded =
      false; // Flag to track if the rewarded ad is loaded.
  var counter =
      0; // Counter to track the number of times the ad has been shown.

  /// Loads a rewarded ad with the given unit ID and configuration.
  void load() {
    try {
      _isRewardedAdLoaded = false;
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
            _isRewardedAdLoaded = true;
          },
          // Called if the ad fails to load.
          onAdFailedToLoad: (LoadAdError error) {
            AdStats.instance.rewardedFailed
                .value++; // Increment ad load failure count.
            _rewardedAd = null;
            _isRewardedAdLoaded = false;
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
      if (_isRewardedAdLoaded &&
          _rewardedAd != null &&
          counter >= getRewardedCounter) {
        counter = 0; // Reset the counter after showing the ad.

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
        counter++; // Increment the counter if ad is not shown yet.
        callBack(); // Callback if the ad is not shown.
      }
    } else {
      callBack(); // Callback if ads shouldn't be shown.
    }
  }
}
