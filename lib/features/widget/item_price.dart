import 'package:flutter/material.dart';

import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../translations/export_lang.dart';

class ItemPrice extends StatelessWidget {
  const ItemPrice({super.key, required this.index, required this.point});
  final Map<String, dynamic> point;
  final int index;

  @override
  Widget build(BuildContext context) {
    final firstTime = point['total'] != null;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: point['selected'] ? lightSalmon : grey200, width: 2),
              color: grey200,
              borderRadius: BorderRadius.circular(16)),
          padding: EdgeInsets.symmetric(
              vertical: index == 0 ? 24 : 16, horizontal: 16),
          child: Row(
            crossAxisAlignment: point['bonus'] != 0
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: point['bonus'] != 0
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    Image.asset(point['selected'] ? checkbox : checkbox_dis,
                        width: 28, height: 28),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatToken(context).format(point['token']) +
                              ' ${LocaleKeys.tokens.tr()}',
                          style: callout(color: grey1100),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (point['bonus'] != 0)
                              Text(
                                '+${formatToken(context).format(point['bonus'])} ${firstTime ? '' : LocaleKeys.tokens.tr()}',
                                style:
                                    subhead(color: grey600, fontWeight: '400'),
                              ),
                            if (firstTime)
                              RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                  text:
                                      ' +${formatToken(context).format(point['total'])}',
                                  style:
                                      subhead(color: corn1, fontWeight: '400'),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: ' ${LocaleKeys.tokens.tr()}',
                                      style: subhead(
                                          color: grey600, fontWeight: '400'),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$ ${point['money']}',
                    style: title4(color: grey1100),
                  ),
                  const SizedBox(height: 8),
                  point['useful'] != null
                      ? Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: index == 2 ? 4 : 8),
                          decoration: BoxDecoration(
                              color: index == 2 ? corn2 : green,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            point['useful'],
                            style: index == 2
                                ? body(color: primary, fontWeight: '700')
                                : caption1(color: grey1100),
                          ),
                        )
                      : const SizedBox()
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
