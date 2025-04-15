import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../preload_ad.dart';

class RewardAd {
  static final RewardAd instance = RewardAd._internal();

  factory RewardAd() {
    return instance;
  }

  RewardAd._internal();

  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;
  var counter = 0;

  void load() {
    try {
      _isRewardedAdLoaded = false;
      RewardedAd.load(
        adUnitId: PreloadAds.instance.initialData.rewardedId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            AdStats.instance.rewardedLoad.value++;
            AppLogger.log("inter loaded");
            _rewardedAd = ad;
            _rewardedAd!.setImmersiveMode(true);
            _isRewardedAdLoaded = true;
          },
          onAdFailedToLoad: (LoadAdError error) {
            AdStats.instance.rewardedFailed.value++;
            _rewardedAd = null;
            _isRewardedAdLoaded = false;
          },
        ),
      );
    } catch (error) {
      _rewardedAd?.dispose();
    }
  }

  void showRewarded({
    required Function() callBack,
    required Function() onReward,
  }) {
    if (PreloadAds.instance.initialData.showRewarded == true &&
        PreloadAds.instance.initialData.showAd == true) {
      if (_isRewardedAdLoaded &&
          _rewardedAd != null &&
          counter >= PreloadAds.instance.initialData.rewardedCounter) {
        counter = 0;

        _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _rewardedAd = null;
            load(); // Load the next ad
          },
          onAdImpression: (ad) {
            AdStats.instance.rewardedImp.value++;
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            AppLogger.error('$ad failed to show: $error');
            _rewardedAd = null;
            ad.dispose();
            load();
          },
        );

        _rewardedAd!.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
            /// ✅ Give the reward to the user
            onReward();
          },
        );
      } else {
        counter++;
        callBack();

        /// Not ready yet, just continue
      }
    } else {
      callBack();

      /// Ads not enabled
    }
  }
}
