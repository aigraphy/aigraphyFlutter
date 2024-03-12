import 'package:flutter/material.dart';

class AdsApplovinBanner extends StatefulWidget {
  const AdsApplovinBanner({Key? key}) : super(key: key);

  @override
  State<AdsApplovinBanner> createState() => _AdsNativeApplovinState();
}

class _AdsNativeApplovinState extends State<AdsApplovinBanner> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
    // return MaxAdView(
    //     adUnitId: AdLovinUtils().bannerAdUnitIdApplovin,
    //     adFormat: AdFormat.banner,
    //     listener: AdViewAdListener(
    //         onAdLoadedCallback: (ad) {},
    //         onAdLoadFailedCallback: (adUnitId, error) {},
    //         onAdClickedCallback: (ad) {},
    //         onAdExpandedCallback: (ad) {},
    //         onAdRevenuePaidCallback: (ad) {
    //           FirebaseAnalytics.instance
    //               .logEvent(name: 'ad_impression', parameters: {
    //             'ad_platform': 'appLovin',
    //             'ad_unit_name': ad.adUnitId,
    //             'ad_format': 'banner',
    //             'ad_source': ad.networkName,
    //             'value': ad.revenue,
    //             'currency': 'USD'
    //           });
    //         },
    //         onAdCollapsedCallback: (ad) {}));
  }
}
