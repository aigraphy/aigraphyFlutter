import 'package:flutter/material.dart';
import 'package:image_editor_plus/image_editor_plus.dart';

import '../config/config_color.dart';

class ButtonOption extends StatelessWidget {
  const ButtonOption({
    super.key,
    this.onTap,
    this.onLongPress,
    required this.icon,
    required this.text,
  });
  final VoidCallback? onTap, onLongPress;
  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Image.asset(
              icon,
              width: 24,
              height: 24,
              color: white,
            ),
            const SizedBox(height: 8),
            Text(
              i18n(text),
            ),
          ],
        ),
      ),
    );
  }
}
