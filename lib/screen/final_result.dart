import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lottie/lottie.dart';

import '../../translations/export_lang.dart';
import '../aigraphy_widget.dart';
import '../bloc/person/bloc_person.dart';
import '../bloc/rem_bg_img/bloc_rem_bg_img.dart';
import '../bloc/swap_img/bloc_swap_img.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../config_router/name_router.dart';
import '../widget/appbar_custom.dart';
import '../widget/banner_ads.dart';
import '../widget/cached_image.dart';
import '../widget/click_widget.dart';
import '../widget/coin_bonus.dart';
import '../widget/expandable_custom.dart';
import '../widget/get_more_coin.dart';
import '../widget/lottie_custom.dart';
import '../widget/offer_first_time.dart';
import '../widget/rem_bg.dart';
import '../widget/share_result.dart';
import '../widget/text_gradient.dart';
import 'editor_img.dart';
import 'in_app_purchase.dart';

class FinalResult extends StatefulWidget {
  const FinalResult(
      {super.key,
      required this.dstPath,
      required this.srcPath,
      required this.srcImage,
      required this.dstImage,
      this.isSwapCate = false});
  final String srcPath;
  final String dstPath;
  final Uint8List srcImage;
  final Uint8List dstImage;
  final bool isSwapCate;
  @override
  State<FinalResult> createState() => _FinalResultState();
}

class _FinalResultState extends State<FinalResult>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  User userFB = FirebaseAuth.instance.currentUser!;
  String? imageRemoveBG;
  PageController? controller;

  void navigatePop() {
    context.read<RemBGImgBloc>().add(const ResetRemBGImg(hasLoaded: true));
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    controller!.dispose();
    imageRemoveBG = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        navigatePop();
        return false;
      },
      child: Scaffold(
        appBar: AppBarCustom(
          left: ClickWidget(
              function: () {
                navigatePop();
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child:
                    Image.asset(arrowLeft, width: 24, height: 24, color: white),
              )),
          center: context.watch<SwapImgBloc>().state is SwapImgLoading
              ? TextGradient(
                  LocaleKeys.replaceMask.tr(),
                  style: const TextStyle(
                      fontSize: 32,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'ClashGrotesk'),
                  gradient: Theme.of(context).linerPimary,
                )
              : const SizedBox(),
          right: context.watch<SwapImgBloc>().state is SwapImgLoaded
              ? ClickWidget(
                  function: () {
                    navigatePop();
                    if (!widget.isSwapCate) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Image.asset(
                      ic_home,
                      width: 24,
                      height: 24,
                      color: white,
                    ),
                  ))
              : const SizedBox(width: 24),
        ),
        floatingActionButton: const OfferFirstTime(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar:
            BlocBuilder<SwapImgBloc, SwapImgState>(builder: (context, state) {
          if (state is SwapImgError) {
            return Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AigraphyWidget.buttonGradient(
                      context: context,
                      input: LocaleKeys.generateAgain.tr(),
                      textColor: white,
                      onPressed: () {
                        final userModel = context.read<PersonBloc>().userModel!;
                        if (userModel.coin >= TOKEN_SWAP) {
                          context.read<SwapImgBloc>().add(InitialSwapImg(
                              context: context,
                              srcPath: widget.srcPath,
                              dstPath: widget.dstPath,
                              fromCate: widget.isSwapCate,
                              handleCoin: true));
                        } else {
                          showModalBottomSheet<void>(
                            context: context,
                            backgroundColor: spaceCadet,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10)),
                            ),
                            builder: (BuildContext context) {
                              return const GetMoreCoin();
                            },
                          );
                        }

                        _controller.repeat(period: const Duration(seconds: 1));
                      }),
                  const SizedBox(height: 8),
                  if (!isIOS) const BannerAds()
                ],
              ),
            );
          } else if (state is SwapImgLoaded) {
            return Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ClickWidget(
                            function: context.watch<RemBGImgBloc>().url == null
                                ? () async {
                                    showModalBottomSheet<void>(
                                      context: context,
                                      backgroundColor: spaceCadet,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(24))),
                                      builder: (BuildContext ctx) {
                                        return RemBg(
                                            ctx: context,
                                            link: state.url!,
                                            requestId: state.requestId!);
                                      },
                                    );
                                  }
                                : () {},
                            child: AigraphyWidget.option(ic_removebg,
                                iconColor:
                                    context.watch<RemBGImgBloc>().url != null
                                        ? cadetBlueCrayola
                                        : white)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClickWidget(
                            function: () async {
                              if (state.fromCate!) {
                                showModalBottomSheet<void>(
                                  context: context,
                                  backgroundColor: spaceCadet,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        topLeft: Radius.circular(10)),
                                  ),
                                  builder: (BuildContext context) {
                                    return ShareResult(
                                        historyId: state.requestId!,
                                        linkImage: state.url!);
                                  },
                                );
                              } else {
                                EasyLoading.show();
                                if (imageRemoveBG != null) {
                                  await shareMultiUrl(
                                      [state.url!, imageRemoveBG!], context);
                                } else {
                                  await shareMultiUrl([state.url!], context);
                                }
                                EasyLoading.dismiss();
                              }
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                AigraphyWidget.option(share),
                                const Positioned(
                                    top: -8, right: -4, child: CoinBonus())
                              ],
                            )),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClickWidget(
                            function: () async {
                              EasyLoading.show();
                              if (imageRemoveBG != null) {
                                await downMultiImg(
                                    [state.url!, imageRemoveBG!]);
                              } else {
                                await downMultiImg([state.url!]);
                              }
                              EasyLoading.dismiss();
                            },
                            child: AigraphyWidget.option(download)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClickWidget(
                            function: () async {
                              final editedImage = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SingleImageEditor(image: state.imageRes!),
                                ),
                              ) as Map<String, dynamic>?;
                              if (editedImage != null) {
                                context.read<SwapImgBloc>().add(EditSwapImg(
                                    result: editedImage['uint8list'],
                                    requestId: editedImage['request']!.id,
                                    url: editedImage['request'].imageRes));
                              }
                            },
                            child:
                                AigraphyWidget.option(paint, color: yellow1)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text:
                          '${formatCoin(context).format(context.watch<PersonBloc>().userModel!.coin)} ${LocaleKeys.coinsRemaining.tr()} ',
                      style: style9(color: white),
                      children: <TextSpan>[
                        TextSpan(
                          text: LocaleKeys.buyMore.tr(),
                          style: style9(color: yellow2),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.of(context).pushNamed(
                                  Routes.in_app_purchase,
                                  arguments: InAppPurchase());
                            },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  AigraphyWidget.buttonGradientAfter(
                      context: context,
                      input:
                          '${LocaleKeys.generateOtherImage.tr()} -$TOKEN_SWAP',
                      icon: coin,
                      sizeAsset: 16,
                      textColor: white,
                      onPressed: () {
                        navigatePop();
                        if (!widget.isSwapCate) {
                          Navigator.of(context).pop();
                        }
                      }),
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: BannerAds(),
                  ),
                ],
              ),
            );
          } else {
            return isIOS
                ? const SizedBox()
                : const Padding(
                    padding: EdgeInsets.only(bottom: 24, left: 8, right: 8),
                    child: BannerAds(),
                  );
          }
        }),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          children: [
            BlocBuilder<SwapImgBloc, SwapImgState>(builder: (context, state) {
              if (state is SwapImgError) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            widget.srcImage,
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
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            widget.dstImage,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        )
                      ],
                    ),
                    const LottieCustom(lottie: swap_failed, height: 300),
                    Align(
                      alignment: Alignment.center,
                      child: TextGradient(
                        LocaleKeys.generateFailed.tr(),
                        style: const TextStyle(
                            fontSize: 40,
                            height: 1,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'ClashGrotesk'),
                        gradient: Theme.of(context).linerPimary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 48, top: 8),
                      child: Text(
                        '${LocaleKeys.someThingWentWrong.tr()}. ${LocaleKeys.youDontLost.tr()}',
                        textAlign: TextAlign.center,
                        style: style7(color: white),
                      ),
                    ),
                  ],
                );
              }
              if (state is SwapImgLoaded) {
                _controller.stop();
                return Column(
                  children: [
                    BlocBuilder<RemBGImgBloc, RemBGImgState>(
                        builder: (context, st) {
                      if (st is RemoveBGImageLoaded) {
                        imageRemoveBG = st.url;
                        if (controller!.hasClients) {
                          controller!.animateToPage(1,
                              duration: const Duration(milliseconds: 100),
                              curve: Curves.easeInOutCubic);
                        }
                      }
                      return ExpandableCustom(
                        children: [
                          Stack(
                            children: [
                              CachedImage(link: state.url!),
                              Positioned(
                                  right: 8,
                                  bottom: 8,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                      widget.dstImage,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                    ),
                                  ))
                            ],
                          ),
                          if (imageRemoveBG != null)
                            CachedImage(link: imageRemoveBG!),
                        ],
                        controller: controller,
                        animationDuration: const Duration(milliseconds: 50),
                      );
                    }),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    LocaleKeys.prepareToDisplay.tr(),
                    style: style7(color: isabelline),
                  ),
                  Lottie.asset(
                    faceJson,
                    controller: _controller,
                    onLoaded: (composition) {
                      _controller
                        ..duration = composition.duration
                        ..repeat();
                    },
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
