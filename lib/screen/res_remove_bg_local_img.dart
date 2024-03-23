import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../translations/export_lang.dart';
import '../aigraphy_widget.dart';
import '../bloc/person/bloc_person.dart';
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
import '../widget/offer_first_time.dart';
import 'editor_img.dart';
import 'in_app_purchase.dart';

class ResRemBgLocalImg extends StatefulWidget {
  const ResRemBgLocalImg({super.key, required this.url, this.requestId});
  final String url;
  final int? requestId;
  @override
  State<ResRemBgLocalImg> createState() => _ResRemBgLocalImgState();
}

class _ResRemBgLocalImgState extends State<ResRemBgLocalImg>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late String imageRemoveBG;

  void navigatePop() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    imageRemoveBG = widget.url;
  }

  @override
  void dispose() {
    _controller.dispose();
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
                          await downloadMultiImage([imageRemoveBG]);
                          EasyLoading.dismiss();
                        },
                        child: AigraphyWidget.option(download)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClickWidget(
                        function: () async {
                          EasyLoading.show();
                          await shareContentMultiUrl([imageRemoveBG], context);
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
                        child: AigraphyWidget.option(paint, color: yellow1)),
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
              AigraphyWidget.typeButtonStartAction(
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
            CachedImage(link: imageRemoveBG),
          ],
        ),
      ),
    );
  }
}
