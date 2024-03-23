import 'package:flutter/material.dart';

class NativeMediumAds extends StatefulWidget {
  const NativeMediumAds({Key? key, this.showAdsWhenNotHave = false})
      : super(key: key);
  final bool showAdsWhenNotHave;

  @override
  State<NativeMediumAds> createState() => _AdsNativeApplovinState();
}

class _AdsNativeApplovinState extends State<NativeMediumAds>
    with AutomaticKeepAliveClientMixin {
  bool hasAds = false;
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const SizedBox();
  }
}
