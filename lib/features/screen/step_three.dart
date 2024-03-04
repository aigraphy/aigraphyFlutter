import 'dart:typed_data';

import 'package:aigraphy_flutter/common/widget/lottie_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lottie/lottie.dart';

import '../../app/widget_support.dart';
import '../../common/bloc/user/bloc_user.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/route/routes.dart';
import '../../common/widget/ads_applovin_banner.dart';
import '../../common/widget/animation_click.dart';
import '../../common/widget/app_bar_cpn.dart';
import '../../common/widget/gradient_text.dart';
import '../../translations/export_lang.dart';
import '../bloc/generate_image/bloc_generate_image.dart';
import '../bloc/remove_bg_image/bloc_remove_bg_image.dart';
import '../widget/expandable_page_view.dart';
import '../widget/gift_widget.dart';
import '../widget/loading_image.dart';
import '../widget/not_enough_token.dart';
import '../widget/remove_bg.dart';
import '../widget/token_bonus.dart';
import 'edit_image.dart';
import 'price.dart';

class StepThree extends StatefulWidget {
  const StepThree(
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
  State<StepThree> createState() => _StepThreeState();
}

class _StepThreeState extends State<StepThree> with TickerProviderStateMixin {
  late final AnimationController _controller;
  User firebaseUser = FirebaseAuth.instance.currentUser!;
  String? imageRemoveBG;
  PageController? controller;

  void navigatePop() {
    context
        .read<RemoveBGImageBloc>()
        .add(const ResetRemoveBGImage(hasLoaded: true));
    // checkHasAds();
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    controller = PageController();
    // checkHasAds();
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
        appBar: AppBarCpn(
          left: AnimationClick(
              function: () {
                navigatePop();
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Image.asset(icArrowLeft,
                    width: 24, height: 24, color: grey1100),
              )),
          center:
              context.watch<GenerateImageBloc>().state is GenerateImageLoading
                  ? GradientText(
                      LocaleKeys.replaceMask.tr(),
                      style: const TextStyle(
                          fontSize: 32,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'ClashGrotesk'),
                      gradient: Theme.of(context).colorLinear,
                    )
                  : const SizedBox(),
          right: context.watch<GenerateImageBloc>().state is GenerateImageLoaded
              ? AnimationClick(
                  function: () {
                    showRating(context);
                    navigatePop();
                    if (!widget.isSwapCate) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Image.asset(ic_house, width: 24, height: 24),
                  ))
              : const SizedBox(width: 24),
        ),
        floatingActionButton: const GiftWidget(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: BlocBuilder<GenerateImageBloc, GenerateImageState>(
            builder: (context, state) {
          if (state is GenerateImageError) {
            return Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppWidget.typeButtonGradient(
                      context: context,
                      input: LocaleKeys.generateAgain.tr(),
                      textColor: grey1100,
                      onPressed: () {
                        final userModel = context.read<UserBloc>().userModel!;
                        if (userModel.token >= TOKEN_SWAP) {
                          context.read<GenerateImageBloc>().add(
                              InitialGenerateImage(
                                  context: context,
                                  srcPath: widget.srcPath,
                                  dstPath: widget.dstPath,
                                  handleToken: true));
                        } else {
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return const NotEnoughToken();
                            },
                          );
                        }

                        _controller.repeat(period: const Duration(seconds: 1));
                      }),
                  const SizedBox(height: 8),
                  if (!isIOS) const AdsApplovinBanner()
                ],
              ),
            );
          } else if (state is GenerateImageLoaded) {
            return Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AnimationClick(
                            function: () async {
                              EasyLoading.show();
                              if (imageRemoveBG != null) {
                                // AdLovinUtils().showAdIfReady();
                                await downloadMultiImage(
                                    [state.url!, imageRemoveBG!]);
                              } else {
                                // showOpenAdsWhenDownShare();
                                await downloadMultiImage([state.url!]);
                              }
                              EasyLoading.dismiss();
                            },
                            child: AppWidget.option(download)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AnimationClick(
                            function: () async {
                              EasyLoading.show();
                              if (imageRemoveBG != null) {
                                await shareContentMultiUrl(
                                    [state.url!, imageRemoveBG!], context);
                              } else {
                                await shareContentMultiUrl(
                                    [state.url!], context);
                              }
                              EasyLoading.dismiss();
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                AppWidget.option(share),
                                const Positioned(
                                    top: -8, right: -4, child: TokenBonus())
                              ],
                            )),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AnimationClick(
                            function: context.watch<RemoveBGImageBloc>().url ==
                                    null
                                ? () async {
                                    showModalBottomSheet<void>(
                                      context: context,
                                      backgroundColor: grey200,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(24))),
                                      builder: (BuildContext ctx) {
                                        return FractionallySizedBox(
                                          heightFactor: 0.32,
                                          child: RemoveBg(
                                              ctx: context,
                                              link: state.url!,
                                              requestId: state.requestId!),
                                        );
                                      },
                                    );
                                  }
                                : () {},
                            child: AppWidget.option(ic_removebg,
                                iconColor:
                                    context.watch<RemoveBGImageBloc>().url !=
                                            null
                                        ? grey400
                                        : grey1100)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AnimationClick(
                            function: () async {
                              final editedImage = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SingleImageEditor(image: state.imageRes!),
                                ),
                              ) as Map<String, dynamic>;
                              context.read<GenerateImageBloc>().add(
                                  EditGenerateImage(
                                      result: editedImage['uint8list'],
                                      requestId: editedImage['request']!.id,
                                      url: editedImage['request'].imageRes));
                            },
                            child: AppWidget.option(paint, color: corn1)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text:
                          '${formatToken(context).format(context.watch<UserBloc>().userModel!.token)} ${LocaleKeys.tokensRemaining.tr()} ',
                      style: subhead(color: grey1100),
                      children: <TextSpan>[
                        TextSpan(
                          text: LocaleKeys.buyMore.tr(),
                          style: subhead(color: corn2),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.of(context).pushNamed(Routes.price,
                                  arguments: PriceScreen());
                            },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppWidget.typeButtonGradientAfter(
                      context: context,
                      input:
                          '${LocaleKeys.generateOtherImage.tr()} -$TOKEN_SWAP',
                      icon: token,
                      sizeAsset: 16,
                      textColor: grey1100,
                      onPressed: () {
                        showRating(context);
                        navigatePop();
                        if (!widget.isSwapCate) {
                          Navigator.of(context).pop();
                        }
                      }),
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: AdsApplovinBanner(),
                  ),
                ],
              ),
            );
          } else {
            return isIOS
                ? const SizedBox()
                : const Padding(
                    padding: EdgeInsets.only(bottom: 24, left: 8, right: 8),
                    child: AdsApplovinBanner(),
                  );
          }
        }),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          children: [
            BlocBuilder<GenerateImageBloc, GenerateImageState>(
                builder: (context, state) {
              if (state is GenerateImageError) {
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
                          child: Image.asset(icArrowRight,
                              width: 24, height: 24, color: lightSalmon),
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
                    const LottieWidget(lottie: bug_error_2, height: 300),
                    Align(
                      alignment: Alignment.center,
                      child: GradientText(
                        LocaleKeys.generateFailed.tr(),
                        style: const TextStyle(
                            fontSize: 40,
                            height: 1,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'ClashGrotesk'),
                        gradient: Theme.of(context).colorLinear,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 48, top: 8),
                      child: Text(
                        '${LocaleKeys.someThingWentWrong.tr()}. ${LocaleKeys.youDontLost.tr()}',
                        textAlign: TextAlign.center,
                        style: body(color: grey1100),
                      ),
                    ),
                  ],
                );
              }
              if (state is GenerateImageLoaded) {
                _controller.stop();
                return Column(
                  children: [
                    BlocBuilder<RemoveBGImageBloc, RemoveBGImageState>(
                        builder: (context, st) {
                      if (st is RemoveBGImageLoaded) {
                        imageRemoveBG = st.url;
                        if (controller!.hasClients) {
                          controller!.animateToPage(1,
                              duration: const Duration(milliseconds: 100),
                              curve: Curves.easeInOutCubic);
                        }
                      }
                      return ExpandablePageView(
                        children: [
                          Stack(
                            children: [
                              LoadingImage(link: state.url!),
                              Positioned(
                                  left: 8,
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
                            LoadingImage(link: imageRemoveBG!),
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
                    style: body(color: grey600),
                  ),
                  if (context.watch<UserBloc>().userModel!.token < 100) ...[
                    const SizedBox(height: 24),
                    AnimationClick(
                      function: () {
                        Navigator.of(context).pushNamed(Routes.price,
                            arguments: PriceScreen(currentIndex: 2));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                            border: Border.all(color: grey1100),
                            color: grey200,
                            borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(LocaleKeys.youAreRunning.tr(),
                                      style: headline(color: grey1100)),
                                  Text(LocaleKeys.buyMoreTokenNow.tr(),
                                      style: subhead(color: grey500)),
                                ],
                              ),
                            ),
                            Image.asset(icArrowRight,
                                width: 24, height: 24, color: grey1100)
                          ],
                        ),
                      ),
                    )
                  ],
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
