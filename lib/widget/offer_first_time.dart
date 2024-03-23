import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/show_offer/show_offer.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_image.dart';
import '../config_router/name_router.dart';
import '../screen/iap_first_time.dart';
import 'click_widget.dart';

class OfferFirstTime extends StatefulWidget {
  const OfferFirstTime({super.key});

  @override
  State<OfferFirstTime> createState() => _OfferFirstTimeState();
}

class _OfferFirstTimeState extends State<OfferFirstTime> {
  bool firstTime = false;
  @override
  Widget build(BuildContext context) {
    return (firstTime && context.watch<ShowOffer>().state)
        ? ClickWidget(
            function: () {
              FirebaseAnalytics.instance
                  .logEvent(name: 'click_first_time_inapp');
              Navigator.of(context)
                  .pushNamed(Routes.iap_first_time, arguments: IAPFirstTime());
              return;
            },
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      gradient: Theme.of(context).linerPimary,
                      borderRadius: BorderRadius.circular(32)),
                  child: Image.asset(gift, width: 48, height: 48),
                ),
                Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: yellow1),
                      child: Text(
                        'x2',
                        style: style9(color: black, fontWeight: '700'),
                      ),
                    )),
              ],
            ),
          )
        : const SizedBox();
  }
}
