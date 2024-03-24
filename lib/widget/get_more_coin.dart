import 'package:flutter/material.dart';

import '../../translations/export_lang.dart';
import '../aigraphy_widget.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_image.dart';
import '../config_router/name_router.dart';
import '../screen/in_app_purchase.dart';
import 'text_gradient.dart';

class GetMoreCoin extends StatelessWidget {
  const GetMoreCoin({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Image.asset(
              coin,
              width: 64,
              height: 64,
            ),
          ),
          TextGradient(
            LocaleKeys.youDontHave.tr(),
            style: const TextStyle(
                fontSize: 28,
                height: 1,
                fontWeight: FontWeight.w700,
                fontFamily: 'ClashGrotesk'),
            gradient: Theme.of(context).linerPimary,
          ),
          const SizedBox(height: 4),
          TextGradient(
            LocaleKeys.enoughCoin.tr(),
            style: const TextStyle(
                fontSize: 28,
                height: 1,
                fontWeight: FontWeight.w700,
                fontFamily: 'ClashGrotesk'),
            gradient: Theme.of(context).linerPimary,
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 8, bottom: 16, left: 24, right: 24),
            child: Text(
              LocaleKeys.tryToBuy.tr(),
              textAlign: TextAlign.center,
              style: style9(color: white, fontWeight: '400'),
            ),
          ),
          AigraphyWidget.buttonGradient(
              context: context,
              input: LocaleKeys.buyMoreCoin.tr(),
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.in_app_purchase,
                    arguments: InAppPurchase());
              },
              textColor: white),
          const SizedBox(height: 16),
          AigraphyWidget.buttonCustom(
              context: context,
              input: LocaleKeys.cancel.tr(),
              vertical: 16,
              onPressed: () {
                Navigator.of(context).pop();
              },
              bgColor: blackCoral,
              borderColor: blackCoral,
              textColor: white),
        ],
      ),
    );
  }
}
