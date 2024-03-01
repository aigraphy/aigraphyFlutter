import 'package:flutter/material.dart';

import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';

class TokenBonus extends StatelessWidget {
  const TokenBonus({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: gradient(context),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            token,
            width: 14,
            height: 14,
          ),
          Text(
            '+$TOKEN_SHARE',
            style: footnote(color: grey100, fontWeight: '700'),
          ),
        ],
      ),
    );
  }
}
