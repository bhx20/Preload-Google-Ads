import '../ad_internal.dart';

/// A singleton class to manage loading and showing rewarded interstitial ads.
class RewardInterAd extends BaseAdLoader {
  /// Singleton instance of [RewardInterAd].
  static final RewardInterAd instance = RewardInterAd._internal();

  /// Factory constructor to provide access to the singleton [RewardInterAd].
  factory RewardInterAd() => instance;

  /// Private constructor for [RewardInterAd] singleton.
  RewardInterAd._internal();

  @override
  bool get isEnabled => shouldShowRewardedInterAd;

  @override
  String get adLabel => "Rewarded Interstitial";

  /// Stores the loaded rewarded interstitial ad.
  RewardedInterstitialAd? _rewardedInterstitialAd;

  /// Loads a rewarded interstitial ad with the configured unit ID.
  @override
  void load() {
    if (!prepareLoad()) return;

    try {
      RewardedInterstitialAd.load(
        adUnitId: unitIDRewardedInter,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            AdStats.instance.rewardedInterLoad.value++;
            _rewardedInterstitialAd = ad;
            _rewardedInterstitialAd!.setImmersiveMode(true);
            handleLoadSuccess();
          },
          onAdFailedToLoad: (LoadAdError error) {
            _rewardedInterstitialAd = null;
            AdStats.instance.rewardedInterFailed.value++;
            handleFailureAndRetry(error);
          },
        ),
      );
    } catch (error) {
      state = AdLoadState.failed;
      _rewardedInterstitialAd?.dispose();
    }
  }

  /// Shows the rewarded interstitial ad if loaded.
  void showRewardedInter({
    required Function({RewardedInterstitialAd? ad, AdError? error}) callBack,
    required Function(AdWithoutView ad, RewardItem reward) onReward,
  }) {
    if (shouldShowRewardedInterAd && _rewardedInterstitialAd != null && isAdLoaded) {
      // Check if ad expired (AdMob 4-hour TTL rule)
      if (isExpired) {
        AppLogger.warn('Rewarded Interstitial ad expired. Fetching fresh ad.');
        _rewardedInterstitialAd?.dispose();
        _rewardedInterstitialAd = null;
        loadTime = null;
        state = AdLoadState.initial;
        load();
        callBack();
        return;
      }

      resetCounter();
      state = AdLoadState.showing;

      _rewardedInterstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          callBack(ad: ad as RewardedInterstitialAd?);
          ad.dispose();
          _rewardedInterstitialAd = null;
          state = AdLoadState.initial;
          load();
        },
        onAdImpression: (ad) {
          AdStats.instance.rewardedInterImp.value++;
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          callBack(ad: ad as RewardedInterstitialAd?, error: error);
          AppLogger.error('$ad failed to show: $error');
          _rewardedInterstitialAd = null;
          ad.dispose();
          state = AdLoadState.failed;
          load();
        },
      );

      _rewardedInterstitialAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          onReward(ad, reward);
        },
      );
    } else {
      incrementCounter();
      if (!isAdLoaded || _rewardedInterstitialAd == null) {
        load(); // Recovery load if missing or network restored
      }
      callBack();
    }
  }

  /// Resets the ad state and disposes loaded ads.
  @override
  void reset() {
    _rewardedInterstitialAd?.dispose();
    _rewardedInterstitialAd = null;
    super.reset();
  }
}
