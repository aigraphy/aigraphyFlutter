import 'package:applovin_max/applovin_max.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import '../constant/colors.dart';
import '../helper_ads/ads_lovin_utils.dart';

class AdsNativeApplovinNormal extends StatefulWidget {
  const AdsNativeApplovinNormal({Key? key, this.showAdsWhenNotHave = false})
      : super(key: key);
  final bool showAdsWhenNotHave;
  @override
  State<AdsNativeApplovinNormal> createState() => _AdsNativeApplovinState();
}

class _AdsNativeApplovinState extends State<AdsNativeApplovinNormal>
    with AutomaticKeepAliveClientMixin {
  final MaxNativeAdViewController _nativeAdViewController =
      MaxNativeAdViewController();
  bool hasAds = false;
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const SizedBox();
    // return Container(
    //   margin: EdgeInsets.all(hasAds ? 8 : 4),
    //   decoration: BoxDecoration(
    //     borderRadius: BorderRadius.circular(16),
    //     color: hasAds ? grey200 : grey100,
    //   ),
    //   child: MaxNativeAdView(
    //     adUnitId: AdLovinUtils().nativeAdUnitIdApplovin,
    //     controller: _nativeAdViewController,
    //     height: widget.showAdsWhenNotHave
    //         ? 165
    //         : hasAds
    //             ? 165
    //             : 1,
    //     listener: NativeAdListener(
    //         onAdLoadedCallback: (ad) {
    //           setState(() {
    //             hasAds = true;
    //           });
    //           Future.delayed(const Duration(seconds: 30)).whenComplete(() {
    //             _nativeAdViewController.loadAd();
    //           });
    //         },
    //         onAdLoadFailedCallback: (adUnitId, error) {
    //           Future.delayed(const Duration(seconds: 15)).whenComplete(() {
    //             _nativeAdViewController.loadAd();
    //           });
    //         },
    //         onAdClickedCallback: (ad) {},
    //         onAdRevenuePaidCallback: (ad) {
    //           FirebaseAnalytics.instance
    //               .logEvent(name: 'ad_impression', parameters: {
    //             'ad_platform': 'appLovin',
    //             'ad_unit_name': ad.adUnitId,
    //             'ad_format': 'native',
    //             'ad_source': ad.networkName,
    //             'value': ad.revenue,
    //             'currency': 'USD'
    //           });
    //         }),
    //     child: Padding(
    //       padding: const EdgeInsets.all(16),
    //       child: Stack(
    //         children: [
    //           Column(
    //             mainAxisSize: MainAxisSize.min,
    //             children: [
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   Container(
    //                     padding: const EdgeInsets.all(4.0),
    //                     child: const MaxNativeAdIconView(
    //                       width: 48,
    //                       height: 48,
    //                     ),
    //                   ),
    //                   const Flexible(
    //                     child: Padding(
    //                       padding: EdgeInsets.only(left: 4),
    //                       child: Column(
    //                         mainAxisAlignment: MainAxisAlignment.start,
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           MaxNativeAdTitleView(
    //                             style: TextStyle(
    //                                 fontWeight: FontWeight.bold, fontSize: 16),
    //                             maxLines: 1,
    //                             overflow: TextOverflow.visible,
    //                           ),
    //                           SizedBox(height: 4),
    //                           MaxNativeAdAdvertiserView(
    //                             style: TextStyle(
    //                                 fontWeight: FontWeight.normal,
    //                                 fontSize: 10),
    //                             maxLines: 1,
    //                             overflow: TextOverflow.fade,
    //                           ),
    //                           MaxNativeAdStarRatingView(
    //                             size: 10,
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               const Row(
    //                 mainAxisAlignment: MainAxisAlignment.start,
    //                 children: [
    //                   Flexible(
    //                     child: MaxNativeAdBodyView(
    //                       style: TextStyle(
    //                           fontWeight: FontWeight.normal, fontSize: 14),
    //                       maxLines: 1,
    //                       overflow: TextOverflow.ellipsis,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               const SizedBox(height: 8),
    //               hasAds
    //                   ? Expanded(
    //                       child: Container(
    //                         decoration: BoxDecoration(
    //                             borderRadius: BorderRadius.circular(16),
    //                             gradient: const LinearGradient(
    //                                 colors: [emerald1, corn2])),
    //                         width: double.infinity,
    //                         child: MaxNativeAdCallToActionView(
    //                           style: TextButton.styleFrom(
    //                             padding: const EdgeInsets.symmetric(
    //                                 vertical: 16, horizontal: 0),
    //                             side: const BorderSide(color: primary),
    //                             shape: RoundedRectangleBorder(
    //                                 borderRadius: BorderRadius.circular(16)),
    //                             backgroundColor: primary,
    //                             minimumSize: const Size(double.infinity, 0),
    //                           ),
    //                         ),
    //                       ),
    //                     )
    //                   : const SizedBox(),
    //             ],
    //           ),
    //           const Positioned(
    //             right: 4,
    //             top: 4,
    //             child: MaxNativeAdOptionsView(
    //               width: 20,
    //               height: 20,
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
