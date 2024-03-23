import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../translations/export_lang.dart';
import '../aigraphy_widget.dart';
import '../bloc/set_index_bottombar/set_index_bottombar_bloc.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_image.dart';
import '../config_router/name_router.dart';
import '../screen/in_app_purchase.dart';
import 'appbar_custom.dart';
import 'click_widget.dart';
import 'text_gradient.dart';

class ResultFeedback extends StatelessWidget {
  const ResultFeedback({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
          left: ClickWidget(
        function: () {
          Navigator.of(context).pop();
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Image.asset(
            icClose,
            width: 24,
            height: 24,
            color: white,
          ),
        ),
      )),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Image.asset(success, width: 120)),
            const SizedBox(height: 24),
            TextGradient(
              LocaleKeys.thankFor.tr(),
              style: const TextStyle(
                  fontSize: 30,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'ClashGrotesk'),
              gradient: Theme.of(context).linerPimary,
            ),
            const SizedBox(height: 8),
            TextGradient(
              LocaleKeys.yourFeedback.tr(),
              style: const TextStyle(
                  fontSize: 30,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'ClashGrotesk'),
              gradient: Theme.of(context).linerPimary,
            ),
            const SizedBox(height: 24),
            Text(
              LocaleKeys.weTakeNote.tr(),
              textAlign: TextAlign.center,
              style: style7(color: white),
            ),
            const SizedBox(height: 24),
            AigraphyWidget.typeButtonGradient(
                context: context,
                input: LocaleKeys.swapFaceNow.tr(),
                vertical: 16,
                onPressed: () {
                  context.read<SetIndexBottomBar>().setIndex(0);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                bgColor: blue,
                borderColor: blue,
                textColor: white),
            const SizedBox(height: 16),
            AigraphyWidget.typeButtonStartAction(
                context: context,
                input: LocaleKeys.buyMoreCoin.tr(),
                vertical: 16,
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(Routes.in_app_purchase,
                      arguments: InAppPurchase());
                },
                bgColor: blackCoral,
                borderColor: blackCoral,
                textColor: white),
          ],
        ),
      ),
    );
  }
}
