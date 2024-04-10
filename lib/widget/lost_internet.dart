import 'package:flutter/material.dart';

import '../aigraphy_widget.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_image.dart';
import '../translations/export_lang.dart';
import 'lottie_custom.dart';

class LostInternet extends StatelessWidget {
  const LostInternet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: LottieCustom(
              lottie: lost_internet,
              height: 250,
            ),
          ),
          Text(
            'No Internet connection. Please check your network connection.',
            textAlign: TextAlign.center,
            style: style6(color: white, fontWeight: '400'),
          ),
          const SizedBox(height: 16),
          AigraphyWidget.buttonGradient(
              context: context,
              input: 'Reload App',
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
              textColor: white),
          const SizedBox(height: 16),
          AigraphyWidget.buttonCustom(
              context: context,
              input: LocaleKeys.cancel.tr(),
              vertical: 16,
              onPressed: () {
                Navigator.of(context).pop();
              },
              bgColor: blackCoral,
              borderColor: blackCoral,
              textColor: white),
        ],
      ),
    );
  }
}
