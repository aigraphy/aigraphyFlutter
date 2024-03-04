import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/set_user_pro/set_user_pro_bloc.dart';
import '../../common/bloc/user/bloc_user.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/route/routes.dart';
import '../../common/widget/animation_click.dart';
import '../screen/price.dart';
import '../screen/price_first_time.dart';

class GoPro extends StatelessWidget {
  const GoPro({super.key, this.text = 'Go Pro'});
  final String text;
  @override
  Widget build(BuildContext context) {
    return AnimationClick(
      function: () {
        if (context.read<SetUserPro>().state) {
          Navigator.of(context)
              .pushNamed(Routes.price, arguments: PriceScreen());
        } else {
          Navigator.of(context)
              .pushNamed(Routes.price_first_time, arguments: PriceFirstTime());
        }
      },
      child: context.watch<SetUserPro>().state
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: grey200, borderRadius: BorderRadius.circular(24)),
              child: Row(
                children: [
                  Image.asset(token, width: 20, height: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${formatToken(context).format(context.watch<UserBloc>().userModel?.token ?? 0)}',
                    style: headline(color: grey1100),
                  )
                ],
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                  color: corn1, borderRadius: BorderRadius.circular(24)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    ic_pro,
                    width: 20,
                    height: 20,
                    color: grey100,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    text,
                    style: headline(color: grey100),
                  )
                ],
              ),
            ),
    );
  }
}
