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
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/route/routes.dart';
import '../../common/util/authentication_apple.dart';
import '../../common/util/authentication_google.dart';
import '../../common/util/login_hasura.dart';
import '../../common/widget/gradient_text.dart';
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
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Image.asset(
          landings[index],
          width: width,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GradientText(
                titles[index]['title1']!,
                style: const TextStyle(
                    fontSize: 36,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'ClashGrotesk'),
                gradient: Theme.of(context).colorLinear,
              ),
              GradientText(
                titles[index]['title2']!,
                style: const TextStyle(
                    fontSize: 36,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'ClashGrotesk'),
                gradient: Theme.of(context).colorLinear,
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
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          CarouselSlider.builder(
              itemCount: landings.length,
              itemBuilder:
                  (BuildContext context, int itemIndex, int pageViewIndex) =>
                      landing(context, itemIndex, width, height),
              options: CarouselOptions(
                enableInfiniteScroll: false,
                height: height / 1.3,
                viewportFraction: 1,
                disableCenter: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
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
          Padding(
            padding: const EdgeInsets.only(left: 32, right: 32, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 24),
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
                if (Platform.isIOS) ...[
                  Row(children: [
                    Expanded(
                      child: AppWidget.typeButtonStartAction2(
                          context: context,
                          input: 'Apple',
                          onPressed: () async {
                            final User firebaseUser =
                                await AuthenticationApple.signInWithApple(
                                    context: context);
                            await signIn(context, firebaseUser);
                          },
                          bgColor: grey1100,
                          icon: apple,
                          borderRadius: 32,
                          colorAsset: grey100,
                          sizeAsset: 24,
                          borderColor: grey1100,
                          textColor: grey100),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppWidget.typeButtonStartAction2(
                          context: context,
                          input: 'Google',
                          onPressed: isChecked
                              ? () async {
                                  final User firebaseUser =
                                      await AuthenticationGoogle
                                          .signInWithGoogle(context: context);
                                  await signIn(context, firebaseUser);
                                }
                              : () {},
                          bgColor: radicalRed2,
                          icon: google,
                          borderRadius: 32,
                          sizeAsset: 24,
                          colorAsset: grey1100,
                          borderColor: radicalRed2,
                          textColor: grey1100),
                    )
                  ])
                ] else ...{
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
                      borderRadius: 32,
                      sizeAsset: 24,
                      colorAsset: grey1100,
                      borderColor: radicalRed2,
                      textColor: grey1100)
                },
              ],
            ),
          )
        ],
      ),
    );
  }
}
