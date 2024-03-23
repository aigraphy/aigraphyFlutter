import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/person/bloc_person.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../config_router/name_router.dart';
import '../screen/in_app_purchase.dart';
import 'click_widget.dart';

class CoinWidget extends StatelessWidget {
  const CoinWidget({super.key, this.hasFunction = true});
  final bool hasFunction;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ClickWidget(
        function: hasFunction
            ? () {
                Navigator.of(context).pushNamed(Routes.in_app_purchase,
                    arguments: InAppPurchase());
              }
            : () {},
        child: Container(
          margin: const EdgeInsets.only(right: 24),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: hasFunction
                ? BorderRadius.circular(16)
                : const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24)),
            gradient: Theme.of(context).linerPimary,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                coin,
                width: 20,
                height: 20,
              ),
              const SizedBox(
                width: 4,
              ),
              hasFunction
                  ? Text(
                      '${formatCoin(context).format(context.watch<PersonBloc>().userModel?.coin ?? 0)}',
                      style: style6(color: black),
                    )
                  : Text(
                      '+$TOKEN_DAILY',
                      style: style6(color: black),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
