import 'package:flutter/cupertino.dart';

import '../../common/constant/colors.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/route/routes.dart';
import '../../common/widget/animation_click.dart';
import '../screen/price.dart';

class GoProLogo extends StatelessWidget {
  const GoProLogo({super.key, this.text = 'Go Pro'});
  final String text;
  @override
  Widget build(BuildContext context) {
    return AnimationClick(
      function: () {
        Navigator.of(context).pushNamed(Routes.price, arguments: PriceScreen());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
            color: corn1, borderRadius: BorderRadius.circular(24)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              ic_pro,
              width: 12,
              height: 12,
              color: grey100,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: caption1(color: grey100),
            )
          ],
        ),
      ),
    );
  }
}
