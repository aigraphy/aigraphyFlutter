import 'package:flutter/material.dart';
import 'package:image_editor_plus/data/layer.dart';
import 'package:image_editor_plus/modules/colors_picker.dart';

import '../../translations/export_lang.dart';

class TextLayerOverlayCustom extends StatefulWidget {
  const TextLayerOverlayCustom({
    super.key,
    required this.layer,
    required this.index,
    required this.onUpdate,
  });
  final int index;
  final TextLayerData layer;
  final Function onUpdate;

  @override
  _TextLayerOverlayCustomState createState() => _TextLayerOverlayCustomState();
}

class _TextLayerOverlayCustomState extends State<TextLayerOverlayCustom> {
  double slider = 0.0;

  @override
  void initState() {
    //  slider = widget.sizevalue;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Text(
              LocaleKeys.sizeAdjust.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  LocaleKeys.size.tr(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Row(children: [
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    thumbColor: Colors.white,
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
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.layer.backgroundOpacity = 0;
                      widget.onUpdate();
                    });
                  },
                  child: Text(
                    LocaleKeys.reset.tr(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
              ]),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  LocaleKeys.color.tr(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Row(children: [
                const SizedBox(width: 16),
                Expanded(
                  child: BarColorPicker(
                    width: 300,
                    thumbColor: Colors.white,
                    initialColor: widget.layer.color,
                    cornerRadius: 10,
                    pickMode: PickMode.color,
                    colorListener: (int value) {
                      setState(() {
                        widget.layer.color = Color(value);
                        widget.onUpdate();
                      });
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.layer.color = Colors.black;
                      widget.onUpdate();
                    });
                  },
                  child: Text(LocaleKeys.reset.tr(),
                      style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 16),
              ]),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  LocaleKeys.backgroundColor.tr(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Row(children: [
                const SizedBox(width: 16),
                Expanded(
                  child: BarColorPicker(
                    width: 300,
                    initialColor: widget.layer.background,
                    thumbColor: Colors.white,
                    cornerRadius: 10,
                    pickMode: PickMode.color,
                    colorListener: (int value) {
                      setState(() {
                        widget.layer.background = Color(value);
                        widget.onUpdate();
                      });
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.layer.background = Colors.transparent;
                      widget.onUpdate();
                    });
                  },
                  child: Text(
                    LocaleKeys.reset.tr(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
              ]),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  LocaleKeys.backgroundOpacity.tr(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Row(children: [
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 255,
                    divisions: 255,
                    value: widget.layer.backgroundOpacity.toDouble(),
                    thumbColor: Colors.white,
                    onChanged: (double value) {
                      setState(() {
                        widget.layer.backgroundOpacity = value;
                        widget.onUpdate();
                      });
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.layer.backgroundOpacity = 0;
                      widget.onUpdate();
                    });
                  },
                  child: Text(
                    LocaleKeys.reset.tr(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}
