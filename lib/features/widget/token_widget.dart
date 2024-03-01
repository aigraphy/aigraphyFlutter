import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/user/bloc_user.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/route/routes.dart';
import '../../common/widget/animation_click.dart';
import '../screen/price.dart';

class TokenWidget extends StatelessWidget {
  const TokenWidget({super.key, this.hasFunction = true});
  final bool hasFunction;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: AnimationClick(
        function: hasFunction
            ? () {
                Navigator.of(context)
                    .pushNamed(Routes.price, arguments: PriceScreen());
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
            gradient: gradient(context),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                token,
                width: 20,
                height: 20,
              ),
              const SizedBox(
                width: 4,
              ),
              hasFunction
                  ? Text(
                      '${formatToken(context).format(context.watch<UserBloc>().userModel?.token ?? 0)}',
                      style: headline(color: grey100),
                    )
                  : Text(
                      '+$TOKEN_DAILY',
                      style: headline(color: grey100),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
