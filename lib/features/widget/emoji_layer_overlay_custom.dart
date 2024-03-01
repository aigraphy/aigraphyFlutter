import 'package:flutter/material.dart';
import 'package:image_editor_plus/data/layer.dart';

import '../../common/constant/colors.dart';
import '../../translations/export_lang.dart';

class EmojiLayerOverlay extends StatefulWidget {
  const EmojiLayerOverlay({
    super.key,
    required this.layer,
    required this.index,
    required this.onUpdate,
  });
  final int index;
  final EmojiLayerData layer;
  final Function onUpdate;

  @override
  _EmojiLayerOverlayState createState() => _EmojiLayerOverlayState();
}

class _EmojiLayerOverlayState extends State<EmojiLayerOverlay> {
  double slider = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: grey100,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(10), topLeft: Radius.circular(10)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Text(
              LocaleKeys.sizeAdjust.tr(),
              style: const TextStyle(color: grey1100),
            ),
          ),
          Slider(
              activeColor: grey1100,
              inactiveColor: grey600,
              value: widget.layer.size,
              min: 0.0,
              max: 100.0,
              onChangeEnd: (v) {
                setState(() {
                  widget.layer.size = v.toDouble();
                  widget.onUpdate();
                });
              },
              onChanged: (v) {
                setState(() {
                  slider = v;
                  widget.layer.size = v.toDouble();
                  widget.onUpdate();
                });
              }),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
