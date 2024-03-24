import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_editor_plus/options.dart' as o;

import '../../translations/export_lang.dart';
import '../aigraphy_widget.dart';
import '../bloc/rem_bg_img/bloc_rem_bg_img.dart';
import '../bloc/swap_img/bloc_swap_img.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../config_router/name_router.dart';
import '../widget/appbar_custom.dart';
import '../widget/banner_ads.dart';
import '../widget/choose_faces.dart';
import '../widget/click_widget.dart';
import '../widget/dotted_widget.dart';
import '../widget/go_pro.dart';
import '../widget/offer_first_time.dart';
import '../widget/text_gradient.dart';
import 'cropper_img.dart';
import 'final_result.dart';

class SelectFace extends StatefulWidget {
  const SelectFace(
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
  State<SelectFace> createState() => _SelectFaceState();
}

class _SelectFaceState extends State<SelectFace> {
  Uint8List? yourFace;
  String? path;
  bool hasUpdateFace = true;
  User userFB = FirebaseAuth.instance.currentUser!;

  Future<void> cropImage() async {
    final Uint8List? croppedImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CropperImg(
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
      backgroundColor: spaceCadet,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const ChooseFaces(cropImage: true);
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

  Future<void> earnedReward({bool handleCoin = false}) async {
    context.read<RemBGImgBloc>().add(const ResetRemBGImg(hasLoaded: true));
    if (!widget.isImgCate) {
      context.read<SwapImgBloc>().add(InitialSwapImg(
          context: context,
          srcPath: widget.pathSource!,
          dstPath: path!,
          handleCoin: handleCoin));

      Navigator.of(context).pushNamed(Routes.final_result,
          arguments: FinalResult(
              srcImage: widget.bytes!,
              dstImage: yourFace!,
              dstPath: path!,
              srcPath: widget.pathSource!));
    } else {
      final imageSwapTmp = await getUint8List(widget.imageCate!);
      final tempDirImageSwap = await Directory.systemTemp.createTemp();
      final tempFileImageSwap = File(
          '${tempDirImageSwap.path}/${DateTime.now().toIso8601String()}.jpg');
      await tempFileImageSwap.writeAsBytes(imageSwapTmp);
      final imageSwap = imageSwapTmp;
      final pathImageSwap = tempFileImageSwap.path;
      context.read<SwapImgBloc>().add(InitialSwapImg(
          context: context,
          srcPath: pathImageSwap,
          dstPath: path!,
          handleCoin: true));

      Navigator.of(context).pushNamed(Routes.final_result,
          arguments: FinalResult(
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
  }

  @override
  Widget build(BuildContext context) {
    final height = AigraphyWidget.getHeight(context);
    final check = path != null && yourFace != null;
    return Scaffold(
      appBar: AppBarCustom(
        left: ClickWidget(
          function: () {
            Navigator.of(context).pop();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Image.asset(
              arrowLeft,
              width: 24,
              height: 24,
              color: white,
            ),
          ),
        ),
        right: Row(
          children: [
            const GoPro(),
            Padding(
              padding: const EdgeInsets.only(right: 24, left: 12),
              child: ClickWidget(
                function: () {
                  Navigator.of(context).pushNamed(Routes.settings);
                },
                child: Image.asset(
                  setting,
                  width: 24,
                  height: 24,
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: const OfferFirstTime(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
        child: check
            ? AigraphyWidget.buttonGradientAfter(
                context: context,
                input: '${LocaleKeys.generate.tr()}  -$TOKEN_SWAP',
                textColor: white,
                icon: coin,
                sizeAsset: 16,
                onPressed: () async {
                  EasyLoading.show();
                  await earnedReward(handleCoin: true);
                  if (hasUpdateFace) {
                    uploadFace(context, yourFace);
                  }
                  EasyLoading.dismiss();
                })
            : AigraphyWidget.buttonCustom(
                context: context,
                input: '${LocaleKeys.generate.tr()}',
                bgColor: spaceCadet,
                textColor: blackCoral,
                borderColor: spaceCadet,
                onPressed: () {
                  BotToast.showText(
                      text: LocaleKeys.youNeedChooseYourFace.tr(),
                      textStyle: style7(color: white));
                }),
      ),
      body: ListView(
        children: [
          if (!isIOS)
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: BannerAds(),
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
                child: Image.asset(arrowRight,
                    width: 24, height: 24, color: white),
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
                    : Image.asset(
                        face_id,
                        width: 68,
                        height: 68,
                        color: cadetBlueCrayola,
                      ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32, top: 24),
            child: yourFace == null
                ? ClickWidget(
                    function: setPhoto,
                    child: const Center(child: DottedWidget()))
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
                                ClickWidget(
                                  function: cropImage,
                                  child: Container(
                                      padding: const EdgeInsets.all(9),
                                      decoration: BoxDecoration(
                                          gradient:
                                              Theme.of(context).linerPimary,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Image.asset(
                                        ic_crop,
                                        width: 16,
                                        height: 16,
                                        color: white,
                                      )),
                                ),
                                const SizedBox(width: 8),
                                ClickWidget(
                                  function: setPhoto,
                                  child: Image.asset(
                                    add_photo,
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
          ),
          Align(
            alignment: Alignment.center,
            child: TextGradient(
              LocaleKeys.yourImage.tr(),
              style: const TextStyle(
                  fontSize: 32,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'ClashGrotesk'),
              gradient: Theme.of(context).linerPimary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 4),
            child: Text(
              LocaleKeys.uploadOrTake.tr(),
              textAlign: TextAlign.center,
              style: style7(color: white),
            ),
          ),
          Text(
            LocaleKeys.pleaseClearFace.tr(),
            textAlign: TextAlign.center,
            style: style7(color: white),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
