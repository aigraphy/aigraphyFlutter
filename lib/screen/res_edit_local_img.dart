import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../translations/export_lang.dart';
import '../aigraphy_widget.dart';
import '../bloc/person/bloc_person.dart';
import '../bloc/rem_bg_img/bloc_rem_bg_img.dart';
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
import '../widget/offer_first_time.dart';
import '../widget/rem_bg.dart';
import 'in_app_purchase.dart';

class ResEditLocalImg extends StatefulWidget {
  const ResEditLocalImg(
      {super.key, required this.imageEdit, required this.requestId});
  final String imageEdit;
  final int requestId;
  @override
  State<ResEditLocalImg> createState() => _ResEditLocalImgState();
}

class _ResEditLocalImgState extends State<ResEditLocalImg>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  String? imageRemoveBG;
  late String imageEdit;
  late int requestId;
  PageController? controller;

  void navigatePop() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    controller = PageController();
    requestId = widget.requestId;
    imageEdit = widget.imageEdit;
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
          right: ClickWidget(
              function: () {
                navigatePop();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Image.asset(swap_cate, width: 24, height: 24),
              )),
        ),
        floatingActionButton: const OfferFirstTime(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ClickWidget(
                        function: () async {
                          EasyLoading.show();
                          if (imageRemoveBG != null) {
                            await downloadMultiImage(
                                [imageEdit, imageRemoveBG!]);
                          } else {
                            await downloadMultiImage([imageEdit]);
                          }
                          EasyLoading.dismiss();
                        },
                        child: AigraphyWidget.option(download)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClickWidget(
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
                                  link: imageEdit,
                                  requestId: requestId);
                            },
                          );
                        },
                        child: AigraphyWidget.option(ic_removebg,
                            iconColor: white)),
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
              AigraphyWidget.buttonCustom(
                  context: context,
                  input: '${LocaleKeys.generateOtherImage.tr()} -$TOKEN_SWAP',
                  bgColor: blue,
                  icon: coin,
                  sizeAsset: 16,
                  textColor: white,
                  borderColor: blue,
                  borderRadius: 12,
                  onPressed: () {
                    navigatePop();
                  }),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: BannerAds(),
              ),
            ],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          children: [
            BlocBuilder<RemBGImgBloc, RemBGImgState>(builder: (context, st) {
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
                  CachedImage(link: imageEdit),
                  if (imageRemoveBG != null) CachedImage(link: imageRemoveBG!),
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
