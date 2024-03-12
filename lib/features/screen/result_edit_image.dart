import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

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
import '../../translations/export_lang.dart';
import '../bloc/remove_bg_image/bloc_remove_bg_image.dart';
import '../widget/expandable_page_view.dart';
import '../widget/gift_widget.dart';
import '../widget/loading_image.dart';
import '../widget/remove_bg.dart';
import '../widget/token_bonus.dart';
import 'price.dart';

class ResultEditImage extends StatefulWidget {
  const ResultEditImage(
      {super.key, required this.imageEdit, required this.requestId});
  final String imageEdit;
  final int requestId;
  @override
  State<ResultEditImage> createState() => _ResultEditImageState();
}

class _ResultEditImageState extends State<ResultEditImage>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  String? imageRemoveBG;
  late String imageEdit;
  late int requestId;
  PageController? controller;

  void navigatePop() {
    checkHasAds();
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    controller = PageController();
    requestId = widget.requestId;
    imageEdit = widget.imageEdit;
    checkHasAds();
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
          right: AnimationClick(
              function: () {
                navigatePop();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Image.asset(house_simple, width: 24, height: 24),
              )),
        ),
        floatingActionButton: const GiftWidget(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: Padding(
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
                            AdLovinUtils().showAdIfReady();
                            await downloadMultiImage(
                                [imageEdit, imageRemoveBG!]);
                          } else {
                            showOpenAdsWhenDownShare();
                            await downloadMultiImage([imageEdit]);
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
                                [imageEdit, imageRemoveBG!], context);
                          } else {
                            await shareContentMultiUrl([imageEdit], context);
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
                        function: () async {
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
                                    link: imageEdit,
                                    requestId: requestId),
                              );
                            },
                          );
                        },
                        child:
                            AppWidget.option(ic_removebg, iconColor: grey1100)),
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
              AppWidget.typeButtonStartAction(
                  context: context,
                  input: '${LocaleKeys.generateOtherImage.tr()} -$TOKEN_SWAP',
                  bgColor: primary,
                  icon: token,
                  sizeAsset: 16,
                  textColor: grey1100,
                  borderColor: primary,
                  borderRadius: 12,
                  onPressed: () {
                    showRating(context);
                    navigatePop();
                  }),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: AdsApplovinBanner(),
              ),
            ],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                  LoadingImage(link: imageEdit),
                  if (imageRemoveBG != null) LoadingImage(link: imageRemoveBG!),
                ],
                controller: controller,
                animationDuration: const Duration(milliseconds: 50),
              );
            }),
          ],
        ),
      ),
    );
  }
}
