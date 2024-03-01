import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_editor_plus/data/layer.dart';
import 'package:image_editor_plus/modules/colors_picker.dart';

import '../../common/constant/colors.dart';
import '../../common/constant/styles.dart';
import '../../common/widget/unfocus_click.dart';
import '../../translations/export_lang.dart';

class TextEditorImage extends StatefulWidget {
  const TextEditorImage({super.key});

  @override
  _TextEditorImageState createState() => _TextEditorImageState();
}

class _TextEditorImageState extends State<TextEditorImage> {
  TextEditingController name = TextEditingController();
  Color currentColor = grey1100;
  double slider = 32.0;
  TextAlign align = TextAlign.left;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: const Icon(
            Icons.arrow_back,
            size: 24,
            color: grey1100,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.alignLeft,
                color: align == TextAlign.left
                    ? grey1100
                    : grey1100.withAlpha(80)),
            onPressed: () {
              setState(() {
                align = TextAlign.left;
              });
            },
          ),
          IconButton(
            icon: Icon(FontAwesomeIcons.alignCenter,
                color: align == TextAlign.center
                    ? grey1100
                    : grey1100.withAlpha(80)),
            onPressed: () {
              setState(() {
                align = TextAlign.center;
              });
            },
          ),
          IconButton(
            icon: Icon(FontAwesomeIcons.alignRight,
                color: align == TextAlign.right
                    ? grey1100
                    : grey1100.withAlpha(80)),
            onPressed: () {
              setState(() {
                align = TextAlign.right;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(
                context,
                TextLayerData(
                  background: Colors.transparent,
                  text: name.text,
                  color: currentColor,
                  size: slider.toDouble(),
                  align: align,
                ),
              );
            },
            color: grey1100,
            padding: const EdgeInsets.all(15),
          )
        ],
      ),
      body: UnfocusClick(
        child: Center(
          child: ListView(children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16),
              child: SizedBox(
                height: size.height / 2.2,
                child: TextField(
                  controller: name,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(10),
                    hintText: LocaleKeys.insertYourMessage.tr(),
                    hintStyle: const TextStyle(color: grey1100),
                    alignLabelWithHint: true,
                  ),
                  scrollPadding: const EdgeInsets.all(20.0),
                  keyboardType: TextInputType.multiline,
                  minLines: 5,
                  maxLines: 100,
                  style: headline(color: currentColor),
                  autofocus: true,
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  LocaleKeys.sliderColor.tr(),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: BarColorPicker(
                    width: 300,
                    thumbColor: grey1100,
                    cornerRadius: 10,
                    pickMode: PickMode.color,
                    colorListener: (int value) {
                      setState(() {
                        currentColor = Color(value);
                      });
                    },
                  ),
                ),
                Text(
                  LocaleKeys.sliderWhiteBlackColor.tr(),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: BarColorPicker(
                    width: 300,
                    thumbColor: grey1100,
                    cornerRadius: 10,
                    pickMode: PickMode.grey,
                    colorListener: (int value) {
                      setState(() {
                        currentColor = Color(value);
                      });
                    },
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 10.0),
                    Center(
                      child: Text(
                        LocaleKeys.sizeAdjust.tr(),
                        style: const TextStyle(color: grey1100),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Slider(
                        activeColor: grey1100,
                        inactiveColor: grey600,
                        value: slider,
                        min: 0.0,
                        max: 100.0,
                        onChangeEnd: (v) {
                          setState(() {
                            slider = v;
                          });
                        },
                        onChanged: (v) {
                          setState(() {
                            slider = v;
                          });
                        }),
                  ],
                )
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
