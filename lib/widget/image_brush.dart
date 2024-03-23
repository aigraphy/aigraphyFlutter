import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hand_signature/signature.dart';
import 'package:image_editor_plus/data/image_item.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_editor_plus/options.dart' as o;
import 'package:screenshot/screenshot.dart';

import '../config/config_color.dart';
import '../config/config_image.dart';

class ImageBrush extends StatefulWidget {
  const ImageBrush({
    super.key,
    required this.image,
    this.options = const o.BrushOption(
      showBackground: true,
      translatable: true,
    ),
  });
  final ImageItem image;
  final o.BrushOption options;

  @override
  State<ImageBrush> createState() => _ImageBrushState();
}

class _ImageBrushState extends State<ImageBrush> {
  Color pickerColor = white,
      currentColor = white,
      currentBackgroundColor = Colors.black;
  var screenshotController = ScreenshotController();

  final control = HandSignatureControl(
    threshold: 3.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );

  List<CubicPath> undoList = [];
  bool skipNextEvent = false;

  void changeColor(o.BrushColor color) {
    currentColor = color.color;
    currentBackgroundColor = color.background;

    setState(() {});
  }

  @override
  void initState() {
    control.addListener(() {
      if (control.hasActivePath) {
        return;
      }

      if (skipNextEvent) {
        skipNextEvent = false;
        return;
      }

      undoList = [];
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SizedBox(
        height: 80,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            ColorButton(
              color: Colors.yellow,
              onTap: (color) {
                showModalBottomSheet(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                  ),
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return Container(
                      color: spaceCadet,
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.only(top: 16),
                          child: HueRingPicker(
                            pickerColor: pickerColor,
                            onColorChanged: (color) {
                              currentColor = color;
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            for (var color in widget.options.colors)
              ColorButton(
                color: color.color,
                onTap: (color) {
                  currentColor = color;
                  setState(() {});
                },
                isSelected: color.color == currentColor,
              ),
          ],
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Image.asset(arrowLeft, width: 24, height: 24, color: white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        actions: [
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            icon: Image.asset(ic_undo,
                width: 24,
                height: 24,
                color: control.paths.isNotEmpty ? white : gray),
            onPressed: () {
              if (control.paths.isEmpty) {
                return;
              }
              skipNextEvent = true;
              undoList.add(control.paths.last);
              control.stepBack();
              setState(() {});
            },
          ),
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            icon: Image.asset(ic_redo,
                width: 24,
                height: 24,
                color: undoList.isNotEmpty ? white : gray),
            onPressed: () {
              if (undoList.isEmpty) {
                return;
              }

              control.paths.add(undoList.removeLast());
              setState(() {});
            },
          ),
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            icon: const Icon(
              Icons.check,
              size: 24,
              color: white,
            ),
            onPressed: () async {
              if (control.paths.isEmpty) {
                return Navigator.pop(context);
              }

              if (widget.options.translatable) {
                final data = await control.toImage(
                  color: currentColor,
                  height: widget.image.height,
                  width: widget.image.width,
                );

                if (!mounted) {
                  return;
                }

                return Navigator.pop(context, data!.buffer.asUint8List());
              }
              EasyLoading.show();
              final image = await screenshotController.capture();
              EasyLoading.dismiss();

              if (!mounted) {
                return;
              }

              return Navigator.pop(context, image);
            },
          ),
        ],
      ),
      body: Screenshot(
        controller: screenshotController,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color:
                widget.options.showBackground ? null : currentBackgroundColor,
            image: widget.options.showBackground
                ? DecorationImage(
                    image: Image.memory(widget.image.bytes).image,
                    fit: BoxFit.contain,
                  )
                : null,
          ),
          child: HandSignature(
            control: control,
            color: currentColor,
            width: 1.0,
            maxWidth: 7.0,
            type: SignatureDrawType.shape,
          ),
        ),
      ),
    );
  }
}
