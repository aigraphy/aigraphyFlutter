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
import '../widget/gift_widget.dart';
import '../widget/loading_image.dart';
import '../widget/token_bonus.dart';
import 'edit_image.dart';
import 'price.dart';

class ResultRemoveBg extends StatefulWidget {
  const ResultRemoveBg({super.key, required this.url, this.requestId});
  final String url;
  final int? requestId;
  @override
  State<ResultRemoveBg> createState() => _ResultRemoveBgState();
}

class _ResultRemoveBgState extends State<ResultRemoveBg>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late String imageRemoveBG;

  void navigatePop() {
    checkHasAds();
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    imageRemoveBG = widget.url;
    checkHasAds();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(imageRemoveBG);
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
                          showOpenAdsWhenDownShare();
                          await downloadMultiImage([imageRemoveBG]);
                          EasyLoading.dismiss();
                        },
                        child: AppWidget.option(download)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AnimationClick(
                        function: () async {
                          EasyLoading.show();
                          await shareContentMultiUrl([imageRemoveBG], context);
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
                          EasyLoading.show();
                          final unit8List = await getImage(imageRemoveBG);
                          EasyLoading.dismiss();
                          final editedImage = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SingleImageEditor(image: unit8List),
                            ),
                          ) as Map<String, dynamic>;
                          setState(() {
                            imageRemoveBG = editedImage['request'].imageRes;
                          });
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
            LoadingImage(link: imageRemoveBG),
          ],
        ),
      ),
    );
  }
}
