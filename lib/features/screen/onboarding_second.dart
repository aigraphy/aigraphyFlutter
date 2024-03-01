import 'package:flutter/material.dart';

import '../../app/widget_support.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/helper_ads/ads_lovin_utils.dart';
import '../../common/preference/shared_preference_builder.dart';
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
  Future<String> checkIntoApp() async {
    String image = onboarding4;
    int count = await getCountIntoApp();
    if (count == 0) {
      image = onboarding4;
    } else if (count == 1) {
      image = onboarding5;
    } else if (count == 2) {
      image = onboarding6;
    } else if (count == 3) {
      image = onboarding7;
    } else {
      count = 0;
    }
    count += 1;
    setCountIntoApp(count);
    return image;
  }

  @override
  void initState() {
    super.initState();
    checkIntoApp();
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
              height: height - 50,
              child: Stack(
                alignment: Alignment.bottomLeft,
                clipBehavior: Clip.none,
                children: [
                  FutureBuilder<String>(
                      future: checkIntoApp(),
                      builder: (context, state) {
                        switch (state.connectionState) {
                          case ConnectionState.active:
                          case ConnectionState.done:
                            return TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0.5, end: 1.0),
                                curve: Curves.ease,
                                duration: const Duration(seconds: 1),
                                builder: (BuildContext context, double opacity,
                                    Widget? child) {
                                  return Opacity(
                                      opacity: opacity,
                                      child: Image.asset(state.data!,
                                          width: width,
                                          height: height - 50,
                                          alignment: Alignment.topCenter,
                                          fit: BoxFit.cover));
                                });
                          default:
                            return Image.asset(onboarding4,
                                width: width,
                                height: height - 135,
                                fit: BoxFit.cover);
                        }
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
                      bottom: 8,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ImageOpacity(
                            milliseconds: 2000,
                            child: SizedBox(
                              width: 150,
                              child: AppWidget.typeButtonStartAction(
                                  context: context,
                                  input: "Let's Start",
                                  borderRadius: 12,
                                  onPressed: () {
                                    AdLovinUtils().showAdIfReady();
                                    Navigator.of(context).pushReplacementNamed(
                                        Routes.bottom_bar,
                                        arguments: const BottomBar());
                                  },
                                  icon: icKeyboardRight,
                                  colorAsset: grey1100,
                                  sizeAsset: 20,
                                  bgColor: primary,
                                  borderColor: primary,
                                  textColor: grey1100),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 32, bottom: 8),
                            child: GradientText(
                              'Welcome Back',
                              style: const TextStyle(
                                  fontSize: 44,
                                  height: 1,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'SpaceGrotesk'),
                              gradient: Theme.of(context).linearGradientCustome,
                            ),
                          ),
                          Text(
                            'Change your face for drawing images in some seconds',
                            style: body(color: grey1100),
                          )
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
