import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../aigraphy_widget.dart';
import '../config/config_color.dart';
import '../config/config_image.dart';

class DottedWidget extends StatelessWidget {
  const DottedWidget({super.key, this.size, this.sizeIcon});
  final double? size;
  final double? sizeIcon;

  @override
  Widget build(BuildContext context) {
    final width = AigraphyWidget.getWidth(context);
    return SizedBox(
      width: size ?? width / 1.5,
      height: size ?? width / 1.5,
      child: DottedBorder(
        color: cadetBlueCrayola,
        borderType: BorderType.RRect,
        dashPattern: const [16, 8],
        radius: Radius.circular(size != null ? 10 : 16),
        child: Center(
          child: Image.asset(
            add_photo,
            width: sizeIcon,
            height: sizeIcon,
          ),
        ),
      ),
    );
  }
}
