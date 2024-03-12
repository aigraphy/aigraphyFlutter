import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_editor_plus/options.dart' as o;

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
import '../../features/screen/step_three.dart';
import '../../features/widget/dotted_image.dart';
import '../../translations/export_lang.dart';
import '../bloc/generate_image/bloc_generate_image.dart';
import '../bloc/remove_bg_image/bloc_remove_bg_image.dart';
import '../widget/gift_widget.dart';
import '../widget/go_pro.dart';
import '../widget/recent_face.dart';
import 'crop_image.dart';

class StepTwo extends StatefulWidget {
  const StepTwo(
      {super.key,
      this.bytes,
      this.pathSource,
      this.isImgCate = false,
      this.imageCate});
  final Uint8List? bytes;
  final String? pathSource;
  final bool isImgCate;
  final String? imageCate;
  @override
  State<StepTwo> createState() => _StepTwoState();
}

class _StepTwoState extends State<StepTwo> {
  Uint8List? yourFace;
  String? path;
  bool hasUpdateFace = true;
  User firebaseUser = FirebaseAuth.instance.currentUser!;

  Future<void> cropImage() async {
    final Uint8List? croppedImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageCropperFreeStyle(
          image: yourFace!,
          availableRatios: const [
            o.AspectRatio(title: 'FREEDOM'),
          ],
        ),
      ),
    );
    if (croppedImage != null) {
      setState(() {
        yourFace = croppedImage;
      });
    }
  }

  Future<void> setPhoto() async {
    await showModalBottomSheet<Map<String, dynamic>>(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: grey200,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const RecentFace(cropImage: true);
      },
      context: context,
    ).then((dynamic value) async {
      if (value != null) {
        setState(() {
          yourFace = value['bytes'];
          path = value['path'];
        });
        if (value['has_update_face'] != null) {
          hasUpdateFace = value['has_update_face'];
        } else {
          hasUpdateFace = true;
        }
      }
    });
  }

  Future<void> earnedReward({bool handleToken = false}) async {
    context
        .read<RemoveBGImageBloc>()
        .add(const ResetRemoveBGImage(hasLoaded: true));
    if (!widget.isImgCate) {
      context.read<GenerateImageBloc>().add(InitialGenerateImage(
          context: context,
          srcPath: widget.pathSource!,
          dstPath: path!,
          handleToken: handleToken));

      Navigator.of(context).pushNamed(Routes.step_three,
          arguments: StepThree(
              srcImage: widget.bytes!,
              dstImage: yourFace!,
              dstPath: path!,
              srcPath: widget.pathSource!));
    } else {
      final imageSwapTmp = await getImage(widget.imageCate!);
      final tempDirImageSwap = await Directory.systemTemp.createTemp();
      final tempFileImageSwap = File(
          '${tempDirImageSwap.path}/${DateTime.now().toIso8601String()}.jpg');
      await tempFileImageSwap.writeAsBytes(imageSwapTmp);
      final imageSwap = imageSwapTmp;
      final pathImageSwap = tempFileImageSwap.path;
      context.read<GenerateImageBloc>().add(InitialGenerateImage(
          context: context,
          srcPath: pathImageSwap,
          dstPath: path!,
          handleToken: true));

      Navigator.of(context).pushNamed(Routes.step_three,
          arguments: StepThree(
              dstPath: path!,
              srcPath: pathImageSwap,
              srcImage: imageSwap,
              isSwapCate: true,
              dstImage: yourFace!));
    }
  }

  Future<void> showChooseFace() async {
    Future.delayed(const Duration(seconds: 1)).whenComplete(() => setPhoto());
  }

  @override
  void initState() {
    super.initState();
    showChooseFace();
    // checkHasAds();
  }

  @override
  Widget build(BuildContext context) {
    final height = AppWidget.getHeightScreen(context);
    final check = path != null && yourFace != null;
    return Scaffold(
      appBar: AppBarCpn(
        left: AnimationClick(
          function: () {
            Navigator.of(context).pop();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Image.asset(
              icArrowLeft,
              width: 24,
              height: 24,
              color: grey1100,
            ),
          ),
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
      floatingActionButton: const GiftWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
        child: check
            ? AppWidget.typeButtonGradientAfter(
                context: context,
                input: '${LocaleKeys.generate.tr()}  -$TOKEN_SWAP',
                textColor: grey1100,
                icon: token,
                sizeAsset: 16,
                onPressed: () async {
                  // final userModel = context.read<UserBloc>().userModel!;
                  // if (userModel.token >= TOKEN_SWAP) {
                  EasyLoading.show();
                  // showInterApplovin(context, () {}, seconds: 5);
                  await earnedReward(handleToken: true);
                  if (hasUpdateFace) {
                    uploadFace(context, yourFace);
                  }
                  EasyLoading.dismiss();
                  // } else {
                  //   showDialog<void>(
                  //     context: context,
                  //     builder: (BuildContext context) {
                  //       return const NotEnoughToken();
                  //     },
                  //   );
                  // }
                })
            : AppWidget.typeButtonStartAction(
                context: context,
                input: '${LocaleKeys.generate.tr()}',
                bgColor: grey200,
                textColor: grey300,
                borderColor: grey200,
                onPressed: () {
                  BotToast.showText(
                      text: LocaleKeys.youNeedChooseYourFace.tr(),
                      textStyle: body(color: grey1100));
                }),
      ),
      body: ListView(
        children: [
          if (!isIOS)
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: AdsApplovinBanner(),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: widget.isImgCate
                    ? Image.network(
                        widget.imageCate!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      )
                    : Image.memory(
                        widget.bytes!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Image.asset(icArrowRight,
                    width: 24, height: 24, color: lightSalmon),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: yourFace != null
                    ? Image.memory(
                        yourFace!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          DottedBorder(
                            color: grey400,
                            borderType: BorderType.RRect,
                            dashPattern: const [8, 4],
                            radius: const Radius.circular(32),
                            child: const SizedBox(
                              height: 62,
                              width: 62,
                            ),
                          ),
                          Positioned(
                              child: Image.asset(
                            smile,
                            width: 28,
                            height: 28,
                            color: grey400,
                          ))
                        ],
                      ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32, top: 24),
            child: yourFace == null
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
                            child: Image.memory(
                              yourFace!,
                              height: height / 2.5,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                            bottom: 8,
                            right: 32,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimationClick(
                                  function: cropImage,
                                  child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          gradient:
                                              Theme.of(context).colorLinear,
                                          borderRadius:
                                              BorderRadius.circular(32)),
                                      child: const Icon(
                                        Icons.crop,
                                        size: 24,
                                        color: grey1100,
                                      )),
                                ),
                                const SizedBox(width: 8),
                                AnimationClick(
                                  function: setPhoto,
                                  child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          gradient:
                                              Theme.of(context).colorLinear,
                                          borderRadius:
                                              BorderRadius.circular(32)),
                                      child: const Icon(
                                        Icons.add,
                                        size: 24,
                                        color: grey1100,
                                      )),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
          ),
          Align(
            alignment: Alignment.center,
            child: GradientText(
              LocaleKeys.yourImage.tr(),
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
              LocaleKeys.uploadOrTake.tr(),
              textAlign: TextAlign.center,
              style: body(color: grey1100),
            ),
          ),
          Text(
            LocaleKeys.pleaseClearFace.tr(),
            textAlign: TextAlign.center,
            style: body(color: grey1100),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
