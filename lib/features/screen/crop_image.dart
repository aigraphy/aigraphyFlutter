import 'dart:async';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image/image.dart' as img;
import 'package:image_editor_plus/options.dart' as o;

import '../../app/widget_support.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/widget/ads_applovin_banner.dart';
import '../../common/widget/animation_click.dart';
import '../../common/widget/app_bar_cpn.dart';
import '../../translations/export_lang.dart';
import '../widget/image_opacity.dart';

class ImageCropperFreeStyle extends StatefulWidget {
  const ImageCropperFreeStyle({
    super.key,
    required this.image,
    this.availableRatios = const [o.AspectRatio(title: 'FREEDOM')],
  });
  final Uint8List image;
  final List<o.AspectRatio> availableRatios;

  @override
  _ImageCropperFreeStyleState createState() => _ImageCropperFreeStyleState();
}

class _ImageCropperFreeStyleState extends State<ImageCropperFreeStyle> {
  final GlobalKey<ExtendedImageEditorState> _controller =
      GlobalKey<ExtendedImageEditorState>();
  late final EditorConfig editorConfig;

  @override
  void initState() {
    super.initState();
    editorConfig = EditorConfig(
      lineColor: grey400,
      cornerColor: grey1000,
      cornerSize: const Size(16, 4),
      lineHeight: 1,
      cropAspectRatio: 1,
      editorMaskColorHandler: (context, pointerDown) => Theme.of(context)
          .scaffoldBackgroundColor
          .withOpacity(pointerDown ? 0.6 : 0.4),
      initCropRectType: InitCropRectType.layoutRect,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCpn(
        left: AnimationClick(
          function: () {
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(left: 24, top: 24),
            decoration: BoxDecoration(
                color: grey200, borderRadius: BorderRadius.circular(48)),
            child: Image.asset(
              icClose,
              width: 20,
              height: 20,
              color: grey1100,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppWidget.typeButtonStartAction2(
                context: context,
                input: LocaleKeys.chooseFace.tr(),
                bgColor: primary,
                textColor: grey1100,
                borderColor: primary,
                borderRadius: 12,
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
            if (!isIOS) const AdsApplovinBanner()
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          ImageOpacity(
              child: Text(
            LocaleKeys.pleaseCropClear.tr(),
            textAlign: TextAlign.center,
            style: body(color: grey1100),
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
}
