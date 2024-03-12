import 'package:flutter/material.dart';

// const double _kMediaViewAspectRatio = 16 / 9;

class AdsNativeApplovinMedium extends StatefulWidget {
  const AdsNativeApplovinMedium({Key? key, this.showAdsWhenNotHave = false})
      : super(key: key);
  final bool showAdsWhenNotHave;

  @override
  State<AdsNativeApplovinMedium> createState() => _AdsNativeApplovinState();
}

class _AdsNativeApplovinState extends State<AdsNativeApplovinMedium>
    with AutomaticKeepAliveClientMixin {
  // final MaxNativeAdViewController _nativeAdViewController =
  //     MaxNativeAdViewController();
  // double _mediaViewAspectRatio = _kMediaViewAspectRatio;
  // late NativeAdListener nativeAdListener;
  bool hasAds = false;
  @override
  bool get wantKeepAlive => true;
  // @override
  // void initState() {
  //   super.initState();
  //   // nativeAdListener = NativeAdListener(
  //   //     onAdLoadedCallback: (ad) {
  //   //       setState(() {
  //   //         _mediaViewAspectRatio =
  //   //             ad.nativeAd?.mediaContentAspectRatio ?? _kMediaViewAspectRatio;
  //   //         hasAds = true;
  //   //       });
  //   //       Future.delayed(const Duration(seconds: 30)).whenComplete(() {
  //   //         _nativeAdViewController.loadAd();
  //   //       });
  //   //     },
  //   //     onAdLoadFailedCallback: (adUnitId, error) {
  //   //       Future.delayed(const Duration(seconds: 15)).whenComplete(() {
  //   //         _nativeAdViewController.loadAd();
  //   //       });
  //   //     },
  //   //     onAdClickedCallback: (ad) {},
  //   //     onAdRevenuePaidCallback: (ad) {
  //   //       FirebaseAnalytics.instance
  //   //           .logEvent(name: 'ad_impression', parameters: {
  //   //         'ad_platform': 'appLovin',
  //   //         'ad_unit_name': ad.adUnitId,
  //   //         'ad_format': 'native',
  //   //         'ad_source': ad.networkName,
  //   //         'value': ad.revenue,
  //   //         'currency': 'USD'
  //   //       });
  //   //     });
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const SizedBox();
    // return Container(
    //   margin: const EdgeInsets.all(8.0),
    //   decoration: BoxDecoration(
    //     borderRadius: BorderRadius.circular(16),
    //     color: hasAds ? grey200 : grey100,
    //   ),
    //   child: MaxNativeAdView(
    //     adUnitId: AdLovinUtils().nativeAdUnitIdApplovin,
    //     controller: _nativeAdViewController,
    //     listener: nativeAdListener,
    //     height: widget.showAdsWhenNotHave
    //         ? 350
    //         : hasAds
    //             ? 350
    //             : 1,
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
    //                       maxLines: 3,
    //                       overflow: TextOverflow.ellipsis,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               const SizedBox(height: 8),
    //               Expanded(
    //                 child: AspectRatio(
    //                   aspectRatio: _mediaViewAspectRatio,
    //                   child: const MaxNativeAdMediaView(),
    //                 ),
    //               ),
    //               const SizedBox(height: 8),
    //               hasAds
    //                   ? SizedBox(
    //                       width: double.infinity,
    //                       child: DecoratedBox(
    //                         decoration: BoxDecoration(
    //                             color: primary,
    //                             borderRadius: BorderRadius.circular(16)),
    //                         child: MaxNativeAdCallToActionView(
    //                           style: TextButton.styleFrom(
    //                             textStyle: headline(context: context),
    //                             padding: const EdgeInsets.symmetric(
    //                                 vertical: 16, horizontal: 8),
    //                             shape: RoundedRectangleBorder(
    //                                 borderRadius: BorderRadius.circular(16)),
    //                             backgroundColor: Colors.transparent,
    //                             shadowColor: Colors.transparent,
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
