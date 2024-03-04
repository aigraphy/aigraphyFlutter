import 'dart:async';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

import '../../app/widget_support.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/route/routes.dart';
import '../../common/widget/ads_applovin_banner.dart';
import '../../common/widget/animation_click.dart';
import '../../common/widget/app_bar_cpn.dart';
import '../../common/widget/gradient_text.dart';
import '../../features/screen/step_two.dart';
import '../../features/widget/dotted_image.dart';
import '../../translations/export_lang.dart';
import '../widget/gift_widget.dart';
import '../widget/go_pro.dart';
import '../widget/list_photo.dart';

class StepOne extends StatefulWidget {
  const StepOne({super.key});

  @override
  State<StepOne> createState() => _StepOneState();
}

class _StepOneState extends State<StepOne> {
  Uint8List? bytes;
  String? path;

  Future<void> setPhoto() async {
    await showModalBottomSheet<Map<String, dynamic>>(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: grey200,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: const ListPhoto());
      },
      context: context,
    ).then((dynamic value) async {
      if (value != null) {
        setState(() {
          bytes = value['bytes'];
          path = value['path'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = AppWidget.getHeightScreen(context);
    return Scaffold(
      appBar: AppBarCpn(
        left: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text('AIGraphy', style: headline(color: grey1100)),
        ),
        right: Row(
          children: [
            const GoPro(),
            Padding(
              padding: const EdgeInsets.only(right: 24, left: 12),
              child: AnimationClick(
                function: () {
                  Navigator.of(context).pushNamed(Routes.menu);
                },
                child: Image.asset(
                  circles_four,
                  width: 24,
                  height: 24,
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const GiftWidget(),
            const SizedBox(height: 8),
            bytes != null
                ? AppWidget.typeButtonGradient(
                    context: context,
                    input: LocaleKeys.next.tr(),
                    textColor: grey1100,
                    onPressed: () {
                      Navigator.of(context).pushNamed(Routes.step_two,
                          arguments: StepTwo(
                            bytes: bytes!,
                            pathSource: path!,
                          ));
                    })
                : AppWidget.typeButtonStartAction(
                    context: context,
                    input: LocaleKeys.next.tr(),
                    bgColor: grey200,
                    textColor: grey300,
                    borderColor: grey200,
                    onPressed: () {
                      BotToast.showText(
                          text: LocaleKeys.youNeedChoose.tr(),
                          textStyle: body(color: grey1100));
                    }),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: ListView(
        children: [
          if (!isIOS)
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: AdsApplovinBanner(),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: bytes == null
                ? AnimationClick(
                    function: setPhoto,
                    child: const Center(child: DottedImage()))
                : Center(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: 200,
                                maxHeight: height / 3,
                              ),
                              child: Image.memory(
                                bytes!,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                            bottom: 8,
                            right: 32,
                            child: AnimationClick(
                              function: setPhoto,
                              child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      gradient: Theme.of(context).colorLinear,
                                      borderRadius: BorderRadius.circular(32)),
                                  child: const Icon(
                                    Icons.add,
                                    size: 24,
                                    color: grey1100,
                                  )),
                            ))
                      ],
                    ),
                  ),
          ),
          Align(
            alignment: Alignment.center,
            child: GradientText(
              LocaleKeys.swapImage.tr(),
              style: const TextStyle(
                  fontSize: 32,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'ClashGrotesk'),
              gradient: Theme.of(context).colorLinear,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Text(
              LocaleKeys.chooseImageYouWant.tr(),
              textAlign: TextAlign.center,
              style: body(color: grey1100),
            ),
          ),
          Text(
            LocaleKeys.pleaseClearFace.tr(),
            textAlign: TextAlign.center,
            style: body(color: grey1100),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
