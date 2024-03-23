import 'package:flutter/material.dart';

import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_image.dart';

class ItemIAP extends StatelessWidget {
  const ItemIAP({super.key, required this.index, required this.point});
  final Map<String, dynamic> point;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: point['selected'] ? yellow1 : gray, width: 2),
              color: spaceCadet,
              borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        '${point['coin']}',
                        style: style5(color: white),
                      ),
                      const SizedBox(width: 4),
                      Image.asset(coin, width: 20, height: 20)
                    ],
                  ),
                  Text(
                    '+${point['bonus']}',
                    style: style9(
                        color: point['bonus'] != 0 ? white : spaceCadet,
                        fontWeight: '400'),
                  )
                ],
              ),
              Text(
                '\$${point['money']}',
                style: style6(color: yellow1),
              ),
            ],
          ),
        ),
        point['useful'] != null
            ? Positioned(
                top: -20,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                      color: point['selected'] ? yellow1 : gray,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12))),
                  child: Text(
                    point['useful'],
                    textAlign: TextAlign.center,
                    style: style12(color: black),
                  ),
                ))
            : const SizedBox()
      ],
    );
  }
}
