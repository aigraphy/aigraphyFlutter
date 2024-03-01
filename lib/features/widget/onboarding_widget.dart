import 'package:flutter/material.dart';

import '../../../common/constant/colors.dart';

mixin OnBoardingWidget {
  static Widget createIndicator(
      {required BuildContext context, int? currentImage, int? lengthImage}) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(lengthImage!, (index) {
          return AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: index == currentImage ? 8 : 8,
              width: index == currentImage ? 8 : 8,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  color: index == currentImage ? grey1100 : grey600));
        }));
  }
}
