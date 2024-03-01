import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/widget_support.dart';
import '../../features/bloc/set_index_bottombar/set_index_bottombar_bloc.dart';
import '../../features/screen/price.dart';
import '../../translations/export_lang.dart';
import '../constant/colors.dart';
import '../constant/images.dart';
import '../constant/styles.dart';
import '../route/routes.dart';
import 'animation_click.dart';
import 'gradient_text.dart';

class ThankFeedback extends StatelessWidget {
  const ThankFeedback({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: grey100,
                        borderRadius: BorderRadius.circular(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                            child:
                                Image.asset(success, width: 150, height: 150)),
                        const SizedBox(height: 24),
                        GradientText(
                          LocaleKeys.thankFor.tr(),
                          style: const TextStyle(
                              fontSize: 30,
                              height: 1,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'SpaceGrotesk'),
                          gradient: Theme.of(context).linearGradientCustome,
                        ),
                        const SizedBox(height: 8),
                        GradientText(
                          LocaleKeys.yourFeedback.tr(),
                          style: const TextStyle(
                              fontSize: 30,
                              height: 1,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'SpaceGrotesk'),
                          gradient: Theme.of(context).linearGradientCustome,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          LocaleKeys.weTakeNote.tr(),
                          textAlign: TextAlign.center,
                          style: body(color: grey1100),
                        ),
                        const SizedBox(height: 24),
                        AppWidget.typeButtonStartAction(
                            context: context,
                            input: LocaleKeys.swapFaceNow.tr(),
                            borderRadius: 12,
                            vertical: 16,
                            onPressed: () {
                              context.read<SetIndexBottomBar>().setIndex(0);
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            bgColor: primary,
                            borderColor: primary,
                            textColor: grey1100),
                        const SizedBox(height: 16),
                        AppWidget.typeButtonStartAction(
                            context: context,
                            input: LocaleKeys.buyMoreToken.tr(),
                            borderRadius: 12,
                            vertical: 16,
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed(Routes.price,
                                  arguments: PriceScreen());
                            },
                            bgColor: grey200,
                            borderColor: grey200,
                            textColor: grey1100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
                left: 32,
                top: 32,
                child: AnimationClick(
                  function: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: grey200,
                        borderRadius: BorderRadius.circular(48)),
                    child: Image.asset(
                      icClose,
                      width: 20,
                      height: 20,
                      color: grey600,
                    ),
                  ),
                ))
          ],
        ),
      ],
    );
  }
}
