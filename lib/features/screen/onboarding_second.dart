import 'package:flutter/material.dart';

import '../../app/widget_support.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/helper_ads/ads_lovin_utils.dart';
import '../../common/route/routes.dart';
import '../../common/widget/gradient_text.dart';
import '../widget/image_opacity.dart';
import 'bottom_bar.dart';

class OnboardingSecond extends StatelessWidget {
  const OnboardingSecond({super.key});

  @override
  Widget build(BuildContext context) {
    final width = AppWidget.getWidthScreen(context);
    final height = AppWidget.getHeightScreen(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                alignment: Alignment.bottomLeft,
                clipBehavior: Clip.none,
                children: [
                  TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.5, end: 1.0),
                      curve: Curves.ease,
                      duration: const Duration(seconds: 1),
                      builder: (BuildContext context, double opacity,
                          Widget? child) {
                        return Opacity(
                            opacity: opacity,
                            child: Image.asset(onboarding4,
                                width: width,
                                height: height,
                                alignment: Alignment.topCenter,
                                fit: BoxFit.cover));
                      }),
                  Positioned(
                    bottom: -1,
                    child: Container(
                      height: height / 3,
                      width: width,
                      decoration: BoxDecoration(
                          gradient: Theme.of(context).colorLinearBottom2),
                    ),
                  ),
                  Positioned(
                      bottom: 24,
                      left: 32,
                      right: 32,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GradientText(
                            'Welcome Back',
                            style: const TextStyle(
                                fontSize: 32,
                                height: 1,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'ClashGrotesk'),
                            gradient: Theme.of(context).colorLinear,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 16),
                            child: Text(
                              'Change your face for drawing images in some seconds',
                              style: body(color: grey1100),
                            ),
                          ),
                          ImageOpacity(
                            milliseconds: 2000,
                            child: SizedBox(
                              width: 150,
                              child: AppWidget.typeButtonGradient(
                                  context: context,
                                  input: "Let's Start",
                                  onPressed: () {
                                    // AdLovinUtils().showAdIfReady();
                                    Navigator.of(context).pushReplacementNamed(
                                        Routes.bottom_bar,
                                        arguments: const BottomBar());
                                  },
                                  bgColor: primary,
                                  borderColor: primary,
                                  textColor: grey1100),
                            ),
                          ),
                        ],
                      ))
                ],
              ),
            ),
          ),
          // const Padding(
          //   padding: EdgeInsets.only(bottom: 24, top: 24),
          //   child: AdsApplovinBanner(),
          // )
        ],
      ),
    );
  }
}
