import 'package:flutter/material.dart';

class NativeNormalAds extends StatefulWidget {
  const NativeNormalAds({Key? key, this.showAdsWhenNotHave = false})
      : super(key: key);
  final bool showAdsWhenNotHave;
  @override
  State<NativeNormalAds> createState() => _AdsNativeApplovinState();
}

class _AdsNativeApplovinState extends State<NativeNormalAds>
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
