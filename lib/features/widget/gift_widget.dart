import 'package:aigraphy_flutter/common/constant/colors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/route/routes.dart';
import '../../common/widget/animation_click.dart';
import '../../common/widget/lottie_widget.dart';
import '../bloc/show_gift/show_gift.dart';
import '../screen/price_first_time.dart';
import '../screen/price_one_time.dart';

class GiftWidget extends StatefulWidget {
  const GiftWidget({super.key});

  @override
  State<GiftWidget> createState() => _GiftWidgetState();
}

class _GiftWidgetState extends State<GiftWidget> {
  bool firstTime = false;
  bool oneTime = false;

  Future<void> checkCustomerInfo() async {
    await Future.delayed(const Duration(seconds: 2));
    final customerInfo = await Purchases.getCustomerInfo();
    if (customerInfo.nonSubscriptionTransactions.isEmpty) {
      firstTime = true;
      context.read<ShowGift>().setShowGift(true);
    } else if (customerInfo.nonSubscriptionTransactions.length == 1) {
      final latestTran = DateTime.parse(
              customerInfo.nonSubscriptionTransactions[0].purchaseDate)
          .toLocal();
      final timeNow = await getTime();
      final isBefore =
          timeNow.isBefore(latestTran.add(const Duration(days: 5)));
      final isAfter = timeNow.isAfter(latestTran.add(const Duration(days: 2)));
      if (isAfter && isBefore) {
        oneTime = true;
        context.read<ShowGift>().setShowGift(true);
      } else {
        context.read<ShowGift>().reset();
      }
    } else {
      firstTime = false;
      oneTime = false;
      context.read<ShowGift>().reset();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    checkCustomerInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (firstTime && context.watch<ShowGift>().state) ||
            (oneTime && context.watch<ShowGift>().state)
        ? AnimationClick(
            function: () {
              if (firstTime) {
                FirebaseAnalytics.instance
                    .logEvent(name: 'click_first_time_inapp');
                Navigator.of(context).pushNamed(Routes.price_first_time,
                    arguments: PriceFirstTime());
                return;
              }
              if (oneTime) {
                FirebaseAnalytics.instance
                    .logEvent(name: 'click_one_time_inapp');
                Navigator.of(context).pushNamed(Routes.price_one_time,
                    arguments: PriceOneTime());
                return;
              }
            },
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      gradient: Theme.of(context).linearGradientCustome,
                      borderRadius: BorderRadius.circular(32)),
                  child: const LottieWidget(lottie: gift, height: 48),
                ),
                Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: corn1),
                      child: Text(
                        'x2',
                        style: subhead(color: grey100, fontWeight: '700'),
                      ),
                    )),
                // context.watch<SetStreamOneTime>().state != null
                //     ? Positioned(
                //         bottom: -8,
                //         child: Container(
                //           decoration: BoxDecoration(
                //               borderRadius: BorderRadius.circular(24),
                //               color: green),
                //           child: SlideCountdown(
                //             streamDuration:
                //                 context.read<SetStreamOneTime>().state,
                //             style: caption2(color: grey1100),
                //             separatorPadding: const EdgeInsets.only(bottom: 2),
                //             padding: const EdgeInsets.symmetric(
                //                 horizontal: 8, vertical: 2),
                //             decoration: const BoxDecoration(
                //               borderRadius:
                //                   BorderRadius.all(Radius.circular(24)),
                //               color: green,
                //             ),
                //           ),
                //         ))
                //     : const SizedBox()
              ],
            ),
          )
        : const SizedBox();
  }
}
