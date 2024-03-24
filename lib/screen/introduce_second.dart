import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../aigraphy_widget.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_image.dart';
import '../config_router/name_router.dart';
import '../widget/banner_ads.dart';
import '../widget/opacity_widget.dart';
import '../widget/text_gradient.dart';
import 'home.dart';

class IntroduceSecond extends StatefulWidget {
  const IntroduceSecond({super.key});

  @override
  State<IntroduceSecond> createState() => _IntroduceSecondState();
}

class _IntroduceSecondState extends State<IntroduceSecond> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(introduce3)
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
    final width = AigraphyWidget.getWidth(context);
    final height = AigraphyWidget.getHeight(context);
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
                          gradient: Theme.of(context).linerIntroduce),
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
                          TextGradient(
                            'Welcome Back',
                            style: const TextStyle(
                                fontSize: 32,
                                height: 1,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'ClashGrotesk'),
                            gradient: Theme.of(context).linerPimary,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 16),
                            child: Text(
                              'Change your face for drawing images in some seconds',
                              style: style7(color: white),
                            ),
                          ),
                          OpacityWidget(
                            milliseconds: 2000,
                            child: SizedBox(
                              width: 150,
                              child: AigraphyWidget.typeButtonGradient(
                                  context: context,
                                  input: "Let's Start",
                                  onPressed: () {
                                    Navigator.of(context).pushReplacementNamed(
                                        Routes.home,
                                        arguments: const Home());
                                  },
                                  bgColor: blue,
                                  borderColor: blue,
                                  textColor: white),
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
            child: BannerAds(),
          )
        ],
      ),
    );
  }
}
