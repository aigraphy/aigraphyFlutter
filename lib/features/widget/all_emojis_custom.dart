import 'package:aigraphy_flutter/common/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_editor_plus/data/data.dart';
import 'package:image_editor_plus/data/layer.dart';

import '../../translations/export_lang.dart';

class Emojies extends StatefulWidget {
  const Emojies({super.key});

  @override
  _EmojiesState createState() => _EmojiesState();
}

class _EmojiesState extends State<Emojies> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(0.0),
        height: 400,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          color: grey100,
          boxShadow: [
            BoxShadow(
              blurRadius: 10.9,
              color: Color.fromRGBO(0, 0, 0, 0.1),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                LocaleKeys.selectEmoji.tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ]),
            const SizedBox(height: 16),
            Container(
              height: 315,
              padding: const EdgeInsets.all(0.0),
              child: GridView(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.all(0),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisSpacing: 0.0,
                  maxCrossAxisExtent: 60.0,
                ),
                children: emojis.map((String emoji) {
                  return GridTile(
                      child: GestureDetector(
                    onTap: () {
                      Navigator.pop(
                        context,
                        EmojiLayerData(
                          text: emoji,
                          size: 32.0,
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.center,
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 35),
                      ),
                    ),
                  ));
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
