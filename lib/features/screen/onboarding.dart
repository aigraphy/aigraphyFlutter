import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../app/widget_support.dart';
import '../../common/bloc/slider/slider_bloc.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/route/routes.dart';
import '../../common/util/authentication_apple.dart';
import '../../common/util/authentication_google.dart';
import '../../common/util/login_hasura.dart';
import '../../common/widget/ads_applovin_banner.dart';
import '../widget/onboarding_widget.dart';
import '../widget/web_view_privacy.dart';
import 'bottom_bar.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  List<String> landings = [
    onboarding1,
    onboarding2,
    onboarding3,
  ];
  List<Map<String, String>> titles = [
    {'title1': 'Swap your face', 'title2': 'to image'},
    {'title1': 'High quality', 'title2': 'render image'},
    {'title1': 'Keep all just', 'title2': 'funny.'}
  ];

  bool isChecked = true;
  Widget landing(BuildContext context, int index, double width, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        index == 2
            ? Expanded(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Image.asset(
                      landings[index],
                      width: width,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              )
            : Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Positioned(
                      left: 32,
                      right: 32,
                      bottom: 24,
                      child: Image.asset(
                        landings[index],
                        height: height / 3,
                      ),
                    ),
                  ],
                ),
              ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titles[index]['title1']!,
                style: header(color: grey1100, letterSpacing: 2),
              ),
              Text(
                titles[index]['title2']!,
                style: header(color: grey1100, letterSpacing: 2),
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<void> signIn(BuildContext context, User firebaseUser) async {
    EasyLoading.show();
    final String? token = await firebaseUser.getIdToken();
    await signInSocials(token!);
    EasyLoading.dismiss();
    Navigator.of(context)
        .pushNamed(Routes.bottom_bar, arguments: const BottomBar());
  }

  @override
  Widget build(BuildContext context) {
    final height = AppWidget.getHeightScreen(context);
    final width = AppWidget.getWidthScreen(context);
    final sliderBloc = context.read<SliderCubit>();
    return Scaffold(
      backgroundColor: grey100,
      bottomNavigationBar: isIOS
          ? const SizedBox()
          : const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: AdsApplovinBanner(),
            ),
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          Stack(
            children: [
              CarouselSlider.builder(
                  itemCount: landings.length,
                  itemBuilder: (BuildContext context, int itemIndex,
                          int pageViewIndex) =>
                      landing(context, itemIndex, width, height),
                  options: CarouselOptions(
                    enableInfiniteScroll: false,
                    height: height / 1.6,
                    viewportFraction: 1,
                    disableCenter: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    onPageChanged: (index, reason) {
                      if (index > sliderBloc.state) {
                        sliderBloc.swipeRight();
                      } else {
                        sliderBloc.swipeLeft();
                      }
                    },
                    scrollDirection: Axis.horizontal,
                  )),
              Positioned(
                top: 64,
                left: 24,
                child: Image.asset(
                  icon_onboarding,
                  width: 56,
                  height: 56,
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 32, right: 32, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 48),
                  child: BlocBuilder<SliderCubit, int>(
                    builder: (context, state) {
                      return OnBoardingWidget.createIndicator(
                          context: context,
                          lengthImage: landings.length,
                          currentImage: state);
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Transform.scale(
                      scale: 1.3,
                      child: Checkbox(
                        checkColor: grey1100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: MaterialStateBorderSide.resolveWith(
                          (states) =>
                              const BorderSide(width: 1.0, color: grey700),
                        ),
                        focusColor: primary,
                        activeColor: primary,
                        value: isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            isChecked = !isChecked;
                          });
                        },
                      ),
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'You agree with our ',
                        style: body(color: grey1100),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Term & Policy',
                            style: headline(color: grey1100),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).pushNamed(Routes.term,
                                    arguments: const WebViewPrivacy());
                              },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // AppWidget.typeButtonStartAction2(
                //     context: context,
                //     input: 'Continue with Facebook',
                //     onPressed: () async {
                //       final User? firebaseUser =
                //           await AuthenticationFacebook.signInWithFacebook(
                //               context: context);
                //       if (firebaseUser != null) {
                //         await signIn(context, firebaseUser);
                //       } else {
                //         BotToast.showText(
                //             text:
                //                 'Error occurred using Facebook Sign-In. Try again.');
                //       }
                //     },
                //     bgColor: primary,
                //     borderColor: primary,
                //     textColor: grey1100,
                //     sizeAsset: 24,
                //     colorAsset: grey1100,
                //     icon: icFacebook),
                // const SizedBox(height: 16),
                if (Platform.isIOS) ...[
                  AppWidget.typeButtonStartAction2(
                      context: context,
                      input: 'Continue with Apple',
                      onPressed: () async {
                        final User firebaseUser =
                            await AuthenticationApple.signInWithApple(
                                context: context);
                        await signIn(context, firebaseUser);
                      },
                      bgColor: grey1100,
                      icon: apple,
                      borderRadius: 12,
                      colorAsset: grey100,
                      sizeAsset: 24,
                      borderColor: grey1100,
                      textColor: grey100),
                  const SizedBox(height: 16),
                ],
                AppWidget.typeButtonStartAction2(
                    context: context,
                    input: 'Continue with Google',
                    onPressed: isChecked
                        ? () async {
                            final User firebaseUser =
                                await AuthenticationGoogle.signInWithGoogle(
                                    context: context);
                            await signIn(context, firebaseUser);
                          }
                        : () {},
                    bgColor: radicalRed2,
                    icon: google,
                    borderRadius: 12,
                    sizeAsset: 24,
                    colorAsset: grey1100,
                    borderColor: radicalRed2,
                    textColor: grey1100)
              ],
            ),
          )
        ],
      ),
    );
  }
}
