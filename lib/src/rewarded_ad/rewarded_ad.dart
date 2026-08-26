import '../ad_internal.dart';

/// A singleton class to manage loading and showing rewarded ads.
class RewardAd extends BaseAdLoader {
  /// Singleton instance of [RewardAd].
  static final RewardAd instance = RewardAd._internal();

  /// Factory constructor to provide access to the singleton [RewardAd].
  factory RewardAd() {
    return instance;
  }

  /// Private constructor for [RewardAd] singleton.
  RewardAd._internal();

  @override
  bool get isEnabled => shouldShowRewardedAd;

  @override
  String get adLabel => "Rewarded";

  RewardedAd? _rewardedAd; // Stores the loaded rewarded ad.

  /// Loads a rewarded ad with the given unit ID and configuration.
  @override
  void load() {
    if (!prepareLoad()) return;
    try {
      RewardedAd.load(
        adUnitId: unitIDRewarded, // ID for the rewarded ad unit.
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          // Called when the ad has successfully loaded.
          onAdLoaded: (ad) {
            AdStats.instance.rewardedLoad.value++; // Increment ad load count.
            _rewardedAd = ad;
            _rewardedAd!.setImmersiveMode(true); // Enable immersive mode.
            handleLoadSuccess();
          },
          // Called if the ad fails to load.
          onAdFailedToLoad: (LoadAdError error) {
            _rewardedAd = null;
            AdStats.instance.rewardedFailed
                .value++; // Increment ad load failure count.
            handleFailureAndRetry(error);
          },
        ),
      );
    } catch (error) {
      state = AdLoadState.failed;
      _rewardedAd?.dispose(); // Dispose ad if there's an error.
    }
  }

  /// Shows the rewarded ad if it is loaded and the conditions are met.
  void showRewarded({
    required Function({RewardedAd? ad, AdError? error}) callBack,
    required Function(AdWithoutView ad, RewardItem reward) onReward,
  }) {
    if (shouldShowRewardedAd && _rewardedAd != null && isAdLoaded) {
      resetCounter(); // Reset the counter after showing the ad.
      state = AdLoadState.showing;

      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        // Called when the ad is dismissed.
        onAdDismissedFullScreenContent: (ad) {
          callBack(ad: ad as RewardedAd?); // Callback after ad is dismissed.
          ad.dispose();
          _rewardedAd = null;
          state = AdLoadState.initial;
          load(); // Reload ad after dismissal.
        },
        // Called when the ad is shown (impression).
        onAdImpression: (ad) {
          AdStats.instance.rewardedImp.value++; // Increment impression count.
        },
        // Called if the ad fails to show.
        onAdFailedToShowFullScreenContent: (ad, error) {
          callBack(ad: ad as RewardedAd?, error: error); // Callback on failure to show.
          AppLogger.error('$ad failed to show: $error');
          _rewardedAd = null;
          ad.dispose();
          state = AdLoadState.failed;
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
      callBack(); // Callback if ads shouldn't be shown or limit not reached.
    }
  }

  /// Resets the ad state and disposes of loaded ads.
  @override
  void reset() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    super.reset();
  }
}
