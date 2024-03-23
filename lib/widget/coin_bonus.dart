import 'package:flutter/material.dart';

import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';

class CoinBonus extends StatelessWidget {
  const CoinBonus({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: Theme.of(context).linerPimary,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            coin,
            width: 14,
            height: 14,
          ),
          Text(
            ' +$TOKEN_SHARE',
            style: style10(color: white, fontWeight: '700'),
          ),
        ],
      ),
    );
  }
}
