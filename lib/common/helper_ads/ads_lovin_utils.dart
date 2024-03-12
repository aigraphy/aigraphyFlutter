import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:applovin_max/applovin_max.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../constant/colors.dart';
// import '../constant/helper.dart';
import '../constant/styles.dart';
import '../preference/shared_preference_builder.dart';

class AdLovinUtils {
  String keySdkApplovin =
      'CfEmtbSTTX1IDgKt5LK7hVynAAoJZIWWLQZmg2H7FaOmbVU9dcK0Jei3BhNgIggFwDiguDhyO3UqdGWol_zv5X';

  String get bannerAdUnitIdApplovin {
    if (Platform.isAndroid) {
      return '62f46409986c160f';
    } else if (Platform.isIOS) {
      return '5daf18a004c476c2';
    }
    throw UnsupportedError('Unsupported platform');
  }

  String get rewardAdUnitIdApplovin {
    if (Platform.isAndroid) {
      return '042ab3d9e1ab4de1';
    } else if (Platform.isIOS) {
      return 'a3fd13a374e1140b';
    }
    throw UnsupportedError('Unsupported platform');
  }

  String get interstitialAdUnitIdApplovin {
    if (Platform.isAndroid) {
      return 'e7a019b93138c555';
    } else if (Platform.isIOS) {
      return 'c1fab4c8bdd295dd';
    }
    throw UnsupportedError('Unsupported platform');
  }

  String get openAdUnitIdApplovin {
    if (Platform.isAndroid) {
      return '34b05314d44ae614';
    } else if (Platform.isIOS) {
      return '3ffaa9f37c91de8b';
    }
    throw UnsupportedError('Unsupported platform');
  }

  String get nativeAdUnitIdApplovin {
    if (Platform.isAndroid) {
      return 'your_native_id';
    } else if (Platform.isIOS) {
      return 'your_native_id';
    }
    throw UnsupportedError('Unsupported platform');
  }

  void initOpenAds() {
    AppLovinMAX.setAppOpenAdListener(AppOpenAdListener(
      onAdLoadedCallback: (ad) {},
      onAdLoadFailedCallback: (adUnitId, error) {},
      onAdDisplayedCallback: (ad) {},
      onAdDisplayFailedCallback: (ad, error) {
        AppLovinMAX.loadAppOpenAd(openAdUnitIdApplovin);
      },
      onAdClickedCallback: (ad) {},
      onAdHiddenCallback: (ad) {
        AppLovinMAX.loadAppOpenAd(openAdUnitIdApplovin);
      },
      onAdRevenuePaidCallback: (ad) {
        // Ghi nhận sự kiện "ad_impression" lên Firebase Analytics
        FirebaseAnalytics.instance.logEvent(name: 'ad_impression', parameters: {
          'ad_platform': 'appLovin',
          'ad_unit_name': ad.adUnitId,
          'ad_format': 'app_open',
          'ad_source': ad.networkName,
          'value': ad.revenue,
          'currency': 'USD'
        });
      },
    ));

    AppLovinMAX.loadAppOpenAd(openAdUnitIdApplovin);
  }

  Future<void> showAdIfReady() async {
    // if (!isIOS) {
    //   final bool isReady =
    //       (await AppLovinMAX.isAppOpenAdReady(openAdUnitIdApplovin))!;
    //   if (isReady) {
    //     AppLovinMAX.showAppOpenAd(openAdUnitIdApplovin);
    //     AppLovinMAX.loadAppOpenAd(openAdUnitIdApplovin);
    //   } else {
    //     AppLovinMAX.loadAppOpenAd(openAdUnitIdApplovin);
    //   }
    // }
  }

  void initializeInterstitialAds(Function displayed) {
    var _interstitialRetryAttempt = 0;
    AppLovinMAX.setInterstitialListener(InterstitialListener(
      onAdLoadedCallback: (ad) {
        // Interstitial ad is ready to be shown. AppLovinMAX.isInterstitialReady(_interstitial_ad_unit_id) will now return 'true'
        print('Interstitial ad loaded from ' + ad.networkName);
        // Reset retry attempt
        _interstitialRetryAttempt = 0;
      },
      onAdRevenuePaidCallback: (MaxAd ad) {
        // Ghi nhận sự kiện "ad_impression" lên Firebase Analytics
        FirebaseAnalytics.instance.logEvent(name: 'ad_impression', parameters: {
          'ad_platform': 'appLovin',
          'ad_unit_name': ad.adUnitId,
          'ad_format': 'interstitial',
          'ad_source': ad.networkName,
          'value': ad.revenue,
          'currency': 'USD'
        });
      },
      onAdLoadFailedCallback: (adUnitId, error) async {
        // Interstitial ad failed to load
        // We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds)
        _interstitialRetryAttempt = _interstitialRetryAttempt + 1;

        final int retryDelay =
            pow(2, min(6, _interstitialRetryAttempt)).toInt();

        print('Interstitial ad failed to load with code ' +
            error.code.toString() +
            ' - retrying in ' +
            retryDelay.toString() +
            's');

        await Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
          AppLovinMAX.loadInterstitial(interstitialAdUnitIdApplovin);
        });
      },
      onAdDisplayedCallback: (ad) {
        displayed();
        AppLovinMAX.loadInterstitial(interstitialAdUnitIdApplovin);
      },
      onAdDisplayFailedCallback: (ad, error) {
        displayed();
      },
      onAdClickedCallback: (ad) {},
      onAdHiddenCallback: (ad) {},
    ));

    // Load the first interstitial
    AppLovinMAX.loadInterstitial(interstitialAdUnitIdApplovin);
  }

  var _rewardedAdRetryAttempt = 0;

  void initializeRewardedAd(Function earnedReward, {int? reward}) {
    AppLovinMAX.setRewardedAdListener(RewardedAdListener(
        onAdLoadedCallback: (ad) {
          // Rewarded ad is ready to be shown. AppLovinMAX.isRewardedAdReady(_rewarded_ad_unit_id) will now return 'true'
          print('Rewarded ad loaded from ' + ad.networkName);

          // Reset retry attempt
          _rewardedAdRetryAttempt = 0;
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          // Rewarded ad failed to load
          // We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds)
          _rewardedAdRetryAttempt = _rewardedAdRetryAttempt + 1;

          final int retryDelay =
              pow(2, min(6, _rewardedAdRetryAttempt)).toInt();
          print('Rewarded ad failed to load with code ' +
              error.code.toString() +
              ' - retrying in ' +
              retryDelay.toString() +
              's');
          Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
            AppLovinMAX.loadRewardedAd(AdLovinUtils().rewardAdUnitIdApplovin);
          });
        },
        onAdDisplayedCallback: (ad) {},
        onAdDisplayFailedCallback: (ad, error) {},
        onAdClickedCallback: (ad) {},
        onAdHiddenCallback: (ad) {},
        onAdReceivedRewardCallback: (ad, rewardItem) {
          FirebaseAnalytics.instance
              .logEvent(name: 'ad_impression', parameters: {
            'ad_platform': 'appLovin',
            'ad_unit_name': ad.adUnitId,
            'ad_format': 'rewarded_video',
            'ad_source': ad.networkName,
            'value': ad.revenue,
            'currency': 'USD'
          });
          if (reward != null) {
            earnedReward(reward);
          } else {
            earnedReward();
          }
        }));
    AppLovinMAX.loadRewardedAd(AdLovinUtils().rewardAdUnitIdApplovin);
  }
}

Future<bool> checkAdsReward() async {
  final bool isReady = (await AppLovinMAX.isRewardedAdReady(
      AdLovinUtils().rewardAdUnitIdApplovin))!;
  return isReady;
}

Future<void> showRewardApplovin(BuildContext context, Function earnedReward,
    {int? reward}) async {
  Timer? timer;
  AdLovinUtils().initializeRewardedAd(earnedReward, reward: reward);
  final bool isReady = await checkAdsReward();
  if (isReady) {
    AppLovinMAX.showRewardedAd(AdLovinUtils().rewardAdUnitIdApplovin);
    return;
  }
  EasyLoading.show();
  timer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
    if (t.tick >= 20) {
      EasyLoading.dismiss();
      BotToast.showText(
          text: 'Reward ad is not ready to be shown. Try again after 1 minutes',
          textStyle: body(color: grey1100));
      timer!.cancel();
    } else {
      final bool isReady = await checkAdsReward();
      if (isReady) {
        EasyLoading.dismiss();
        timer!.cancel();
        AppLovinMAX.showRewardedAd(AdLovinUtils().rewardAdUnitIdApplovin);
      }
    }
  });
}

Future<void> checkHasAds() async {
  // final bool isReady = await checkAds();
  // if (!isReady) {
  //   AdLovinUtils().initializeInterstitialAds(() {});
  // }
}

Future<bool> checkAds() async {
  final bool isReady = (await AppLovinMAX.isInterstitialReady(
      AdLovinUtils().interstitialAdUnitIdApplovin))!;
  return isReady;
}

Future<void> showInterApplovin(BuildContext context, Function displayed,
    {int seconds = 10}) async {
  // Timer? timer;
  // final bool isReady = await checkAds();
  // if (isReady) {
  //   AppLovinMAX.showInterstitial(AdLovinUtils().interstitialAdUnitIdApplovin);
  //   AdLovinUtils().initializeInterstitialAds(displayed);
  //   return;
  // }

  // timer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
  //   if (t.tick >= seconds) {
  //     displayed();
  //     timer!.cancel();
  //   } else {
  //     final bool isReady = await checkAds();
  //     if (isReady) {
  //       timer!.cancel();
  //       AppLovinMAX.showInterstitial(
  //           AdLovinUtils().interstitialAdUnitIdApplovin);
  //       AdLovinUtils().initializeInterstitialAds(displayed);
  //     }
  //   }
  // });
}

Future<void> showOpenAdsWhenDownShare() async {
  int count = await getCountDownImage();
  if (count > 9) {
    AdLovinUtils().showAdIfReady();
    count = 0;
  } else {
    count += 1;
  }
  setCountDownImage(count);
}
