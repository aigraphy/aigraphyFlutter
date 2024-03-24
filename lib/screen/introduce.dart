import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:video_player/video_player.dart';

import '../aigraphy_widget.dart';
import '../bloc/pageview/pageview_bloc.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../config_router/name_router.dart';
import '../util/authen_apple.dart';
import '../util/authen_google.dart';
import '../widget/click_widget.dart';
import '../widget/privacy.dart';
import '../widget/text_gradient.dart';
import 'home.dart';

class Introduce extends StatefulWidget {
  const Introduce({super.key});

  @override
  State<Introduce> createState() => _IntroduceState();
}

class _IntroduceState extends State<Introduce> {
  late VideoPlayerController _controller1;
  late VideoPlayerController _controller2;
  late VideoPlayerController _controller3;

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
              TextGradient(
                titlesIntroduce[index]['title1']!,
                style: const TextStyle(
                    fontSize: 36,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'ClashGrotesk'),
                gradient: Theme.of(context).linerPimary,
              ),
              TextGradient(
                titlesIntroduce[index]['title2']!,
                style: const TextStyle(
                    fontSize: 36,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'ClashGrotesk'),
                gradient: Theme.of(context).linerPimary,
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget buttonLogin(
      {double? fontSize,
      required BuildContext context,
      double? height,
      double? vertical,
      double? horizontal,
      Function()? onPressed,
      Color? bgColor,
      Color? borderColor,
      double miniSizeHorizontal = double.infinity,
      Color? textColor,
      String? input,
      FontWeight? fontWeight,
      double borderRadius = 32,
      double sizeAsset = 16,
      Color? colorAsset,
      String? icon}) {
    return ClickWidget(
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
              vertical: vertical ?? 16, horizontal: horizontal ?? 0),
          side: BorderSide(color: borderColor ?? white),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius)),
          backgroundColor: bgColor,
          minimumSize: Size(miniSizeHorizontal, 0),
        ),
        onPressed: onPressed,
        child: icon == null
            ? Text(
                input!,
                textAlign: TextAlign.center,
                style: style6(context: context, color: textColor),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          child: Image.asset(
                        icon,
                        width: sizeAsset,
                        height: sizeAsset,
                        color: colorAsset,
                      )),
                      const SizedBox(width: 8),
                      Text(
                        input!,
                        textAlign: TextAlign.center,
                        style: style6(context: context, color: textColor),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Future<void> signInSocials(String _token) async {
    try {
      final response =
          await Dio().get<dynamic>('https://aigraphy.vercel.app/webhook',
              options: Options(headers: <String, dynamic>{
                'Authorization': '$_token',
                'content-type': 'application/json',
              }));
      print(response);
    } catch (e) {
      print(e);
    }
  }

  Future<void> signIn(BuildContext context, User userFB) async {
    EasyLoading.show();
    final String? token = await userFB.getIdToken();
    await signInSocials(token!);
    EasyLoading.dismiss();
    Navigator.of(context)
        .pushReplacementNamed(Routes.home, arguments: const Home());
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
    final height = AigraphyWidget.getHeight(context);
    final width = AigraphyWidget.getWidth(context);
    final sliderBloc = context.read<PageViewCubit>();
    return Scaffold(
      backgroundColor: black,
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
                  child: BlocBuilder<PageViewCubit, int>(
                    builder: (context, state) {
                      return AigraphyWidget.createIndicator(
                          context: context,
                          lengthImage: landings.length,
                          currentImage: state);
                    },
                  ),
                ),
                if (Platform.isIOS) ...[
                  Row(children: [
                    Expanded(
                      child: buttonLogin(
                          context: context,
                          input: 'Apple',
                          onPressed: () async {
                            final User userFB =
                                await AuthenApple.signInWithApple(
                                    context: context);
                            await signIn(context, userFB);
                          },
                          bgColor: white,
                          icon: apple,
                          borderRadius: 32,
                          colorAsset: black,
                          sizeAsset: 24,
                          borderColor: white,
                          textColor: black),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: buttonLogin(
                          context: context,
                          input: 'Google',
                          onPressed: () async {
                            final User userFB =
                                await AuthenGoogle.signInWithGoogle(
                                    context: context);
                            await signIn(context, userFB);
                          },
                          bgColor: red2,
                          icon: google,
                          borderRadius: 32,
                          sizeAsset: 24,
                          colorAsset: white,
                          borderColor: red2,
                          textColor: white),
                    )
                  ])
                ] else ...{
                  buttonLogin(
                      context: context,
                      input: 'Continue with Google',
                      onPressed: () async {
                        final User userFB = await AuthenGoogle.signInWithGoogle(
                            context: context);
                        await signIn(context, userFB);
                      },
                      bgColor: red2,
                      icon: google,
                      borderRadius: 32,
                      sizeAsset: 24,
                      colorAsset: white,
                      borderColor: red2,
                      textColor: white)
                },
                const SizedBox(height: 16),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'By logging in, you are agreeing to the ',
                    style: style7(color: white),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Term & Policy',
                        style: style6(color: white),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).pushNamed(Routes.policy,
                                arguments: const Privacy());
                          },
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
