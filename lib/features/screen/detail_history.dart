import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

import '../../app/widget_support.dart';
import '../../common/bloc/list_requests/list_requests_bloc.dart';
import '../../common/bloc/user/bloc_user.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/helper_ads/ads_lovin_utils.dart';
import '../../common/route/routes.dart';
import '../../common/util/upload_image.dart';
import '../../common/widget/ads_applovin_banner.dart';
import '../../common/widget/animation_click.dart';
import '../../common/widget/gradient_text.dart';
import '../../translations/export_lang.dart';
import '../bloc/remove_bg_image/bloc_remove_bg_image.dart';
import '../bloc/set_index_bottombar/set_index_bottombar_bloc.dart';
import '../widget/expandable_page_view.dart';
import '../widget/gift_widget.dart';
import '../widget/loading_image.dart';
import '../widget/remove_bg.dart';
import '../widget/token_bonus.dart';
import 'edit_image.dart';
import 'price.dart';

class DetailHistory extends StatefulWidget {
  const DetailHistory(
      {super.key,
      required this.imageRes,
      required this.idRequest,
      this.imageRemoveBG});
  final String imageRes;
  final int idRequest;
  final String? imageRemoveBG;
  @override
  State<DetailHistory> createState() => _DetailHistoryState();
}

class _DetailHistoryState extends State<DetailHistory> {
  late String urlResult;
  late int idRequest;
  String? imageRemoveBG;
  PageController? controller;

  Future<Uint8List> getImage(String url) async {
    final responseData = await http.get(Uri.parse(url));
    final Uint8List res = responseData.bodyBytes;
    return res;
  }

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
      appBar: AppWidget.createSimpleAppBar(
        context: context,
        action: Image.asset(trash, width: 24, height: 24, color: grey1100),
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            backgroundColor: grey200,
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
                        trash,
                        width: 64,
                        height: 64,
                        color: grey1100,
                      ),
                    ),
                    GradientText(
                      controller!.page!.round() == 0
                          ? LocaleKeys.deleteImage.tr()
                          : LocaleKeys.deleteImageBackground.tr(),
                      style: const TextStyle(
                          fontSize: 32,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'ClashGrotesk'),
                      gradient: Theme.of(context).colorLinear,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: Text(
                        LocaleKeys.itIsImpossible.tr(),
                        textAlign: TextAlign.center,
                        style: body(color: Theme.of(context).color12),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: AppWidget.typeButtonStartAction(
                              context: context,
                              input: LocaleKeys.delete.tr(),
                              onPressed: () {
                                if (controller!.page!.round() == 0) {
                                  deleteFile(urlResult);
                                  if (imageRemoveBG != null) {
                                    deleteFile(imageRemoveBG!);
                                  }
                                  context
                                      .read<ListRequestsBloc>()
                                      .add(RemoveRequest(id: idRequest));
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  return;
                                }
                                if (controller!.page!.round() == 1) {
                                  if (imageRemoveBG != null) {
                                    deleteFile(imageRemoveBG!);
                                  }
                                  context.read<ListRequestsBloc>().add(
                                      RemoveImageBG(
                                          requestId: idRequest,
                                          context: context));
                                  Navigator.of(context).pop();
                                }
                              },
                              bgColor: radicalRed1,
                              borderColor: radicalRed1,
                              textColor: grey1100),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppWidget.typeButtonGradient(
                              context: context,
                              input: LocaleKeys.cancel.tr(),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              textColor: grey1100),
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
      floatingActionButton: const GiftWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
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
                          // AdLovinUtils().showAdIfReady();
                          await downloadMultiImage([urlResult, imageRemoveBG!]);
                        } else {
                          // showOpenAdsWhenDownShare();
                          await downloadMultiImage([urlResult]);
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
                              [urlResult, imageRemoveBG!], context);
                        } else {
                          await shareContentMultiUrl([urlResult], context);
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
                      function: imageRemoveBG == null
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
                                        link: urlResult,
                                        requestId: idRequest),
                                  );
                                },
                              );
                            }
                          : () {},
                      child: AppWidget.option(ic_removebg,
                          iconColor:
                              imageRemoveBG != null ? grey400 : grey1100)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AnimationClick(
                      function: () async {
                        EasyLoading.show();
                        final Uint8List unit8List = await getImage(urlResult);
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
                        Navigator.of(context)
                            .pushNamed(Routes.price, arguments: PriceScreen());
                      },
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),
            AppWidget.typeButtonGradientAfter(
                context: context,
                input: '${LocaleKeys.generateOtherImage.tr()} -$TOKEN_SWAP',
                icon: token,
                sizeAsset: 16,
                textColor: grey1100,
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<SetIndexBottomBar>().setIndex(0);
                }),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: AdsApplovinBanner(),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          BlocBuilder<RemoveBGImageBloc, RemoveBGImageState>(
              builder: (context, state) {
            if (state is RemoveBGImageLoaded) {
              imageRemoveBG = state.url;
              if (controller!.hasClients) {
                controller!.animateToPage(1,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeInOutCubic);
              }
            }
            return ExpandablePageView(
              children: [
                LoadingImage(link: urlResult),
                if (imageRemoveBG != null) LoadingImage(link: imageRemoveBG!),
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
