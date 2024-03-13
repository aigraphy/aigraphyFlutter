import 'package:aigraphy_flutter/common/constant/colors.dart';
import 'package:flutter/material.dart';

import '../../../app/widget_support.dart';
import '../../../common/widget/gradient_text.dart';
import '../../translations/export_lang.dart';
import '../constant/images.dart';
import '../constant/styles.dart';

class RateAppWidget extends StatefulWidget {
  const RateAppWidget({Key? key}) : super(key: key);

  @override
  State<RateAppWidget> createState() => _RateAppWidgetState();
}

class _RateAppWidgetState extends State<RateAppWidget> {
  // /* MUST CONFIG */
  // Future<void> _rateAndReviewApp() async {
  //   final _inAppReview = InAppReview.instance;
  //   _inAppReview.openStoreListing(
  //     appStoreId: '',
  //     microsoftStoreId: '',
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: grey200, borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(success, width: 120),
                DefaultTextStyle(
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 30,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'ClashGrotesk'),
                  child: GradientText(
                    LocaleKeys.enjoyOurApp.tr(),
                    gradient: Theme.of(context).colorLinear,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    LocaleKeys.itGoodRight.tr(),
                    textAlign: TextAlign.center,
                    style: body(color: Theme.of(context).color12),
                  ),
                ),
                const SizedBox(height: 24),
                // AppWidget.typeButtonGradient(
                //     context: context,
                //     input: LocaleKeys.RateNow.tr(),
                //     onPressed: () {
                //       Navigator.of(context).pop();
                //       // _rateAndReviewApp();
                //     },
                //     vertical: 16,
                //     textColor: grey1100),
                // const SizedBox(height: 16),
                AppWidget.typeButtonStartAction(
                    context: context,
                    input: LocaleKeys.later.tr(),
                    vertical: 16,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    bgColor: grey300,
                    borderColor: grey300,
                    textColor: grey1100)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
