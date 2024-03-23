import 'dart:async';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image/image.dart' as img;
import 'package:image_editor_plus/options.dart' as o;

import '../aigraphy_widget.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../translations/export_lang.dart';
import '../widget/appbar_custom.dart';
import '../widget/banner_ads.dart';
import '../widget/click_widget.dart';
import '../widget/opacity_widget.dart';

class CropperImg extends StatefulWidget {
  const CropperImg({
    super.key,
    required this.image,
    this.availableRatios = const [o.AspectRatio(title: 'FREEDOM')],
  });
  final Uint8List image;
  final List<o.AspectRatio> availableRatios;

  @override
  _CropperImgState createState() => _CropperImgState();
}

class _CropperImgState extends State<CropperImg> {
  final GlobalKey<ExtendedImageEditorState> _controller =
      GlobalKey<ExtendedImageEditorState>();
  late final EditorConfig editorConfig;

  Future<Uint8List?> cropImageWithThread({
    required Uint8List imageBytes,
    required Rect rect,
  }) async {
    final img.Command cropTask = img.Command();
    cropTask.decodeImage(imageBytes);

    cropTask.copyCrop(
      x: rect.topLeft.dx.ceil(),
      y: rect.topLeft.dy.ceil(),
      height: rect.height.ceil(),
      width: rect.width.ceil(),
    );

    final img.Command encodeTask = img.Command();
    encodeTask.subCommand = cropTask;
    encodeTask.encodeJpg();

    return encodeTask.getBytesThread();
  }

  @override
  void initState() {
    super.initState();
    editorConfig = EditorConfig(
      lineColor: white,
      cornerColor: gray1000,
      cornerSize: const Size(20, 4),
      cropAspectRatio: CropAspectRatios.ratio1_1,
      editorMaskColorHandler: (context, pointerDown) => Theme.of(context)
          .scaffoldBackgroundColor
          .withOpacity(pointerDown ? 0.6 : 0.4),
      initCropRectType: InitCropRectType.layoutRect,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        left: ClickWidget(
          function: () {
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(left: 24, top: 24),
            decoration: BoxDecoration(
                color: spaceCadet, borderRadius: BorderRadius.circular(48)),
            child: Image.asset(
              icClose,
              width: 20,
              height: 20,
              color: white,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AigraphyWidget.typeButtonGradient(
                context: context,
                input: LocaleKeys.chooseFace.tr(),
                textColor: white,
                onPressed: () async {
                  EasyLoading.show();
                  final state = _controller.currentState;

                  if (state == null || state.getCropRect() == null) {
                    EasyLoading.dismiss();
                    Navigator.pop(context);
                  }

                  final data = await cropImageWithThread(
                    imageBytes: state!.rawImageData,
                    rect: state.getCropRect()!,
                  );
                  EasyLoading.dismiss();
                  if (mounted) {
                    Navigator.pop(context, data);
                  }
                }),
            const SizedBox(height: 8),
            if (!isIOS) const BannerAds()
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          OpacityWidget(
              child: Text(
            LocaleKeys.pleaseCropClear.tr(),
            textAlign: TextAlign.center,
            style: style7(color: white),
          )),
          Expanded(
            child: ExtendedImage.memory(
              widget.image,
              cacheRawData: true,
              enableLoadState: true,
              fit: BoxFit.contain,
              extendedImageEditorKey: _controller,
              mode: ExtendedImageMode.editor,
              initEditorConfigHandler: (_) => editorConfig,
            ),
          ),
        ],
      ),
    );
  }
}
