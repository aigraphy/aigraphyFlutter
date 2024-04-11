import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/set_user_pro/set_user_pro_bloc.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_image.dart';

class GoProLogo extends StatelessWidget {
  const GoProLogo({super.key, this.text = 'Go Pro'});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
          color: yellow1, borderRadius: BorderRadius.circular(24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            ic_pro,
            width: 12,
            height: 12,
            color: black,
          ),
          const SizedBox(width: 4),
          if (!context.watch<SetUserPro>().state)
            Text(
              text,
              style: style12(color: black, fontWeight: '500'),
            )
          else
            Text(
              'Pro',
              style: style12(color: black, fontWeight: '500'),
            )
        ],
      ),
    );
  }
}
