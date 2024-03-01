import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../../app/widget_support.dart';
import '../../common/constant/colors.dart';

class DottedImage extends StatelessWidget {
  const DottedImage({super.key, this.size});
  final double? size;

  @override
  Widget build(BuildContext context) {
    final width = AppWidget.getWidthScreen(context);
    return SizedBox(
      width: size ?? width / 1.8,
      height: size ?? width / 1.8,
      child: DottedBorder(
        color: grey1000,
        borderType: BorderType.RRect,
        dashPattern: const [8, 4],
        radius: Radius.circular(size != null ? 10 : 16),
        child: Center(
          child: Container(
              padding: EdgeInsets.all(size != null ? 4 : 8),
              decoration: BoxDecoration(
                  color: primary, borderRadius: BorderRadius.circular(32)),
              child: Icon(
                Icons.add,
                size: size != null ? 12 : 24,
                color: grey1100,
              )),
        ),
      ),
    );
  }
}
