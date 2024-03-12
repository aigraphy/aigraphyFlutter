import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_player/video_player.dart';

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
  late VideoPlayerController _controller1;
  late VideoPlayerController _controller2;
  late VideoPlayerController _controller3;

  List<String> landings = [
    onboarding1,
    onboarding2,
    onboarding4,
  ];

  List<Map<String, String>> titles = [
    {'title1': 'Swap your face', 'title2': 'to image'},
    {'title1': 'High quality', 'title2': 'render image'},
    {'title1': 'Keep all just', 'title2': 'funny.'}
  ];

  bool isChecked = true;
  Widget landing(BuildContext context, VideoPlayerController _controller,
      int index, double width, double height) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
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
        .pushReplacementNamed(Routes.bottom_bar, arguments: const BottomBar());
    Navigator.of(context).pushNamed(Routes.guide_face);
  }

  @override
  void initState() {
    super.initState();
    _controller1 = VideoPlayerController.asset(landings[0])..initialize();
    _controller2 = VideoPlayerController.asset(landings[1])..initialize();
    _controller3 = VideoPlayerController.asset(landings[2])..initialize();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
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
                  (BuildContext context, int itemIndex, int pageViewIndex) {
                if (itemIndex == 0) {
                  _controller1
                    ..play()
                    ..setLooping(true);
                  return landing(
                      context, _controller1, itemIndex, width, height);
                } else if (itemIndex == 1) {
                  _controller2
                    ..play()
                    ..setLooping(true);
                  return landing(
                      context, _controller2, itemIndex, width, height);
                } else {
                  _controller3
                    ..play()
                    ..setLooping(true);
                  return landing(
                      context, _controller3, itemIndex, width, height);
                }
              },
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
