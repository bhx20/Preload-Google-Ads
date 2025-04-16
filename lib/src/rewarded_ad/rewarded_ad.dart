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
        adUnitId: PreloadGoogleAds.instance.initialData.rewardedId,
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
    if (PreloadGoogleAds.instance.initialData.showRewarded == true &&
        PreloadGoogleAds.instance.initialData.showAd == true) {
      if (_isRewardedAdLoaded &&
          _rewardedAd != null &&
          counter >= PreloadGoogleAds.instance.initialData.rewardedCounter) {
        counter = 0;

        _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            callBack();
            ad.dispose();
            _rewardedAd = null;
            load();
          },
          onAdImpression: (ad) {
            AdStats.instance.rewardedImp.value++;
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            callBack();
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
      }
    } else {
      callBack();
    }
  }
}
