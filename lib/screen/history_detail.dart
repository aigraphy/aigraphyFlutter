import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../translations/export_lang.dart';
import '../aigraphy_widget.dart';
import '../bloc/current_bottombar/current_bottombar_bloc.dart';
import '../bloc/histories/histories_bloc.dart';
import '../bloc/person/bloc_person.dart';
import '../bloc/rem_bg_img/bloc_rem_bg_img.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../config_router/name_router.dart';
import '../util/upload_file_DO.dart';
import '../widget/banner_ads.dart';
import '../widget/cached_image.dart';
import '../widget/click_widget.dart';
import '../widget/coin_bonus.dart';
import '../widget/expandable_custom.dart';
import '../widget/offer_first_time.dart';
import '../widget/rem_bg.dart';
import '../widget/text_gradient.dart';
import 'editor_img.dart';
import 'in_app_purchase.dart';

class HistoryDetail extends StatefulWidget {
  const HistoryDetail(
      {super.key,
      required this.imageRes,
      required this.idRequest,
      this.imageRemoveBG});
  final String imageRes;
  final int idRequest;
  final String? imageRemoveBG;
  @override
  State<HistoryDetail> createState() => _HistoryDetailState();
}

class _HistoryDetailState extends State<HistoryDetail> {
  late String urlResult;
  late int idRequest;
  String? imageRemoveBG;
  PageController? controller;

  @override
  void initState() {
    super.initState();
    urlResult = widget.imageRes;
    idRequest = widget.idRequest;
    imageRemoveBG = widget.imageRemoveBG;
    controller = PageController();
  }

  @override
  void dispose() {
    imageRemoveBG = null;
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AigraphyWidget.createAppBar(
        context: context,
        action: Image.asset(bin, width: 24, height: 24, color: white),
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            backgroundColor: spaceCadet,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Image.asset(
                        bin,
                        width: 64,
                        height: 64,
                        color: white,
                      ),
                    ),
                    TextGradient(
                      controller!.page!.round() == 0
                          ? LocaleKeys.deleteImage.tr()
                          : LocaleKeys.deleteImageBackground.tr(),
                      style: const TextStyle(
                          fontSize: 32,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'ClashGrotesk'),
                      gradient: Theme.of(context).linerPimary,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: Text(
                        LocaleKeys.itIsImpossible.tr(),
                        textAlign: TextAlign.center,
                        style: style7(color: white),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: AigraphyWidget.buttonCustom(
                              context: context,
                              input: LocaleKeys.delete.tr(),
                              onPressed: () {
                                if (controller!.page!.round() == 0) {
                                  deleteFileDO(urlResult);
                                  if (imageRemoveBG != null) {
                                    deleteFileDO(imageRemoveBG!);
                                  }
                                  context
                                      .read<HistoriesBloc>()
                                      .add(RemoveHistory(id: idRequest));
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  return;
                                }
                                if (controller!.page!.round() == 1) {
                                  if (imageRemoveBG != null) {
                                    deleteFileDO(imageRemoveBG!);
                                  }
                                  context.read<HistoriesBloc>().add(RemoveImgBG(
                                      requestId: idRequest, context: context));
                                  Navigator.of(context).pop();
                                }
                              },
                              bgColor: red1,
                              borderColor: red1,
                              textColor: white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AigraphyWidget.buttonGradient(
                              context: context,
                              input: LocaleKeys.cancel.tr(),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              textColor: white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24)
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: const OfferFirstTime(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ClickWidget(
                      function: imageRemoveBG == null
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
                                      link: urlResult,
                                      requestId: idRequest);
                                },
                              );
                            }
                          : () {},
                      child: AigraphyWidget.option(ic_removebg,
                          iconColor: imageRemoveBG != null
                              ? cadetBlueCrayola
                              : white)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClickWidget(
                      function: () async {
                        EasyLoading.show();
                        if (imageRemoveBG != null) {
                          await shareMultiUrl(
                              [urlResult, imageRemoveBG!], context);
                        } else {
                          await shareMultiUrl([urlResult], context);
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
                        EasyLoading.show();
                        if (imageRemoveBG != null) {
                          await downMultiImg([urlResult, imageRemoveBG!]);
                        } else {
                          await downMultiImg([urlResult]);
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
                        final Uint8List unit8List =
                            await getUint8List(urlResult);
                        EasyLoading.dismiss();
                        final editedImage = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SingleImageEditor(image: unit8List),
                          ),
                        ) as Map<String, dynamic>?;
                        if (editedImage != null) {
                          setState(() {
                            idRequest = editedImage['request'].id!;
                            urlResult = editedImage['request'].imageRes;
                            imageRemoveBG = null;
                          });
                        }
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
                        Navigator.of(context).pushNamed(Routes.in_app_purchase,
                            arguments: InAppPurchase());
                      },
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),
            AigraphyWidget.buttonGradientAfter(
                context: context,
                input: '${LocaleKeys.generateOtherImage.tr()} -$TOKEN_SWAP',
                icon: coin,
                sizeAsset: 16,
                textColor: white,
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<CurrentBottomBar>().setIndex(0);
                }),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: BannerAds(),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          BlocBuilder<RemBGImgBloc, RemBGImgState>(builder: (context, state) {
            if (state is RemoveBGImageLoaded) {
              imageRemoveBG = state.url;
              if (controller!.hasClients) {
                controller!.animateToPage(1,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeInOutCubic);
              }
            }
            return ExpandableCustom(
              children: [
                CachedImage(link: urlResult),
                if (imageRemoveBG != null) CachedImage(link: imageRemoveBG!),
              ],
              controller: controller,
              animationDuration: const Duration(milliseconds: 50),
            );
          }),
        ],
      ),
    );
  }
}
