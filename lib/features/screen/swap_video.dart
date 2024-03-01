import 'package:aigraphy_flutter/common/constant/colors.dart';
import 'package:flutter/material.dart';

import '../../common/constant/images.dart';
import '../../common/widget/ads_native_applovin_normal.dart';
import '../../common/widget/gradient_text.dart';
import '../../common/widget/lottie_widget.dart';
import '../../translations/export_lang.dart';
import '../widget/gift_widget.dart';

class SwapVideo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const GiftWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LottieWidget(
              lottie: swapVideo,
              height: 200,
            ),
            const SizedBox(height: 24),
            GradientText(
              LocaleKeys.videoSwap.tr(),
              style: const TextStyle(
                  fontSize: 40,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SpaceGrotesk'),
              gradient: Theme.of(context).linearGradientCustome,
            ),
            const SizedBox(height: 8),
            GradientText(
              LocaleKeys.comingSoon.tr(),
              style: const TextStyle(
                  fontSize: 40,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SpaceGrotesk'),
              gradient: Theme.of(context).linearGradientCustome,
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: AdsNativeApplovinNormal(),
            ),
            const SizedBox(height: 24)
          ],
        ),
      ),
    );
  }
}
