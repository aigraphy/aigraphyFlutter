import 'dart:async';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_editor_plus/options.dart' as o;

import '../../app/widget_support.dart';
import '../../common/bloc/user/bloc_user.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/helper_ads/ads_lovin_utils.dart';
import '../../common/route/routes.dart';
import '../../common/widget/ads_applovin_banner.dart';
import '../../common/widget/animation_click.dart';
import '../../common/widget/app_bar_cpn.dart';
import '../../common/widget/gradient_text.dart';
import '../../features/screen/step_three.dart';
import '../../features/widget/dotted_image.dart';
import '../../features/widget/token_widget.dart';
import '../../translations/export_lang.dart';
import '../bloc/generate_image/bloc_generate_image.dart';
import '../bloc/remove_bg_image/bloc_remove_bg_image.dart';
import '../widget/gift_widget.dart';
import '../widget/not_enough_token.dart';
import '../widget/recent_face.dart';
import 'crop_image.dart';

class StepTwo extends StatefulWidget {
  const StepTwo({super.key, required this.bytes, required this.pathSource});
  final Uint8List bytes;
  final String pathSource;
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
      backgroundColor: grey100,
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

  void earnedReward({bool handleToken = false}) {
    context.read<GenerateImageBloc>().add(InitialGenerateImage(
        context: context,
        srcPath: widget.pathSource,
        dstPath: path!,
        handleToken: handleToken));
    context
        .read<RemoveBGImageBloc>()
        .add(const ResetRemoveBGImage(hasLoaded: true));
    Navigator.of(context).pushNamed(Routes.step_three,
        arguments: StepThree(
            srcImage: widget.bytes,
            dstImage: yourFace!,
            dstPath: path!,
            srcPath: widget.pathSource));
  }

  Future<void> showChooseFace() async {
    Future.delayed(const Duration(seconds: 1)).whenComplete(() => setPhoto());
  }

  @override
  void initState() {
    super.initState();
    showChooseFace();
    checkHasAds();
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
        right: const TokenWidget(),
      ),
      floatingActionButton: const GiftWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
        child: AppWidget.typeButtonStartAction(
            context: context,
            input: '${LocaleKeys.generate.tr()} -$TOKEN_SWAP',
            bgColor: check ? primary : grey200,
            textColor: check ? grey1100 : grey300,
            borderColor: check ? primary : grey200,
            icon: token2,
            colorAsset: check ? null : grey300,
            borderRadius: 12,
            onPressed: check
                ? () {
                    final userModel = context.read<UserBloc>().userModel!;
                    if (userModel.token >= TOKEN_SWAP) {
                      EasyLoading.show();
                      showInterApplovin(context, () {}, seconds: 5);
                      earnedReward(handleToken: true);
                      if (hasUpdateFace) {
                        uploadFace(context, yourFace);
                      }
                      EasyLoading.dismiss();
                    } else {
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return const NotEnoughToken();
                        },
                      );
                    }
                  }
                : () {
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
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
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
                                          color: primary,
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
                                          color: primary,
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
                  fontSize: 40,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SpaceGrotesk'),
              gradient: Theme.of(context).linearGradientCustome,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  widget.bytes,
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
                borderRadius: BorderRadius.circular(12),
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
                            radius: const Radius.circular(16),
                            child: const SizedBox(
                              height: 64,
                              width: 64,
                            ),
                          ),
                          Positioned(
                              child: Image.asset(
                            smile,
                            width: 32,
                            height: 32,
                            color: grey400,
                          ))
                        ],
                      ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
