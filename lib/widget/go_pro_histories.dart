import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/person/bloc_person.dart';
import '../bloc/set_user_pro/set_user_pro_bloc.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../config_router/name_router.dart';
import '../screen/iap_first_time.dart';
import '../screen/in_app_purchase.dart';
import 'click_widget.dart';

class GoProHistories extends StatelessWidget {
  const GoProHistories({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (context.watch<SetUserPro>().state)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
                color: yellow1, borderRadius: BorderRadius.circular(24)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  ic_pro,
                  width: 20,
                  height: 20,
                  color: black,
                ),
                const SizedBox(width: 4),
                Text(
                  'Pro',
                  style: style6(color: black),
                )
              ],
            ),
          ),
        ClickWidget(
          function: () {
            if (context.read<SetUserPro>().state) {
              Navigator.of(context).pushNamed(Routes.in_app_purchase,
                  arguments: InAppPurchase());
            } else {
              Navigator.of(context)
                  .pushNamed(Routes.iap_first_time, arguments: IAPFirstTime());
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: spaceCadet, borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                Image.asset(coin, width: 20, height: 20),
                const SizedBox(width: 4),
                Text(
                  '${formatCoin(context).format(context.watch<PersonBloc>().userModel?.coin ?? 0)}',
                  style: style6(color: white),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
