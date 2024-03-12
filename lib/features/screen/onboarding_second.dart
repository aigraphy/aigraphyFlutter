import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../app/widget_support.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/helper_ads/ads_lovin_utils.dart';
import '../../common/route/routes.dart';
import '../../common/widget/ads_applovin_banner.dart';
import '../../common/widget/gradient_text.dart';
import '../widget/image_opacity.dart';
import 'bottom_bar.dart';

class OnboardingSecond extends StatefulWidget {
  const OnboardingSecond({super.key});

  @override
  State<OnboardingSecond> createState() => _OnboardingSecondState();
}

class _OnboardingSecondState extends State<OnboardingSecond> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    AppLovinMAX.loadAppOpenAd(AdLovinUtils().openAdUnitIdApplovin);
    _controller = VideoPlayerController.asset(onboarding3)
      ..initialize().then((value) {
        setState(() {});
      })
      ..play()
      ..setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                  Align(
                    alignment: Alignment.topCenter,
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
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
                      bottom: 48,
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
                                    AdLovinUtils().showAdIfReady();
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
          const Padding(
            padding: EdgeInsets.only(bottom: 24, top: 24),
            child: AdsApplovinBanner(),
          )
        ],
      ),
    );
  }
}
