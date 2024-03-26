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
import '../widget/cached_image.dart';
import '../widget/click_widget.dart';
import '../widget/coin_bonus.dart';
import '../widget/offer_first_time.dart';
import 'editor_img.dart';
import 'in_app_purchase.dart';

class CombineResult extends StatefulWidget {
  const CombineResult({super.key, required this.urlResult});
  final String urlResult;
  @override
  State<CombineResult> createState() => _CombineResultState();
}

class _CombineResultState extends State<CombineResult> {
  late String urlResult;
  @override
  void initState() {
    super.initState();
    urlResult = widget.urlResult;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
          left: ClickWidget(
              function: () {
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child:
                    Image.asset(arrowLeft, width: 24, height: 24, color: white),
              )),
          right: ClickWidget(
              function: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Image.asset(
                  ic_home,
                  width: 24,
                  height: 24,
                  color: white,
                ),
              ))),
      floatingActionButton: const OfferFirstTime(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ClickWidget(
                      function: () async {
                        EasyLoading.show();
                        await shareMultiUrl([urlResult], context);
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
                        await downMultiImg([urlResult]);
                        EasyLoading.dismiss();
                      },
                      child: AigraphyWidget.option(download)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClickWidget(
                      function: () async {
                        EasyLoading.show();
                        final unit8List = await getUint8List(urlResult);
                        EasyLoading.dismiss();
                        final editedImage = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SingleImageEditor(image: unit8List),
                          ),
                        ) as Map<String, dynamic>?;
                        if (editedImage != null) {
                          urlResult = editedImage['request'].image_res;
                          setState(() {});
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
            AigraphyWidget.buttonGradient(
                context: context,
                input: 'Try Again',
                textColor: white,
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [CachedImage(link: urlResult)],
      ),
    );
  }
}
