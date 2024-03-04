import 'package:flutter/material.dart';

import '../../common/constant/colors.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';

class ItemPrice extends StatelessWidget {
  const ItemPrice({super.key, required this.index, required this.point});
  final Map<String, dynamic> point;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
              border:
                  Border.all(color: point['selected'] ? corn1 : gray, width: 2),
              color: grey200,
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
                        '${point['token']}',
                        style: title4(color: grey1100),
                      ),
                      const SizedBox(width: 4),
                      Image.asset(token, width: 20, height: 20)
                    ],
                  ),
                  Text(
                    '+${point['bonus']}',
                    style: subhead(
                        color: point['bonus'] != 0 ? grey1100 : grey200,
                        fontWeight: '400'),
                  )
                ],
              ),
              Text(
                '\$${point['money']}',
                style: headline(color: corn1),
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
                      color: point['selected'] ? corn1 : gray,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12))),
                  child: Text(
                    point['useful'],
                    textAlign: TextAlign.center,
                    style: caption2(color: grey100),
                  ),
                ))
            : const SizedBox()
      ],
    );
  }
}
