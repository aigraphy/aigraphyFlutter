import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:photo_view/photo_view.dart';

import '../aigraphy_widget.dart';
import '../config/config_color.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../config_router/name_router.dart';
import '../translations/export_lang.dart';
import '../util/upload_file_DO.dart';
import '../widget/choose_photo.dart';
import '../widget/click_widget.dart';
import '../widget/dotted_widget.dart';
import 'combine_result.dart';

class CombineImg extends StatefulWidget {
  const CombineImg({super.key, required this.url});
  final String url;

  @override
  State<CombineImg> createState() => _CombineImgState();
}

class _CombineImgState extends State<CombineImg> {
  final List<String> bgs = [
    bg_1,
    bg_2,
    bg_3,
    bg_4,
    bg_5,
    bg_6,
    bg_7,
    bg_8,
    bg_9,
    bg_10
  ];
  String? bgAvailable;
  Uint8List? bgLocal;
  bool? isLocalBg;
  Offset position = const Offset(0, 0);
  final GlobalKey _globalKey = GlobalKey();
  Uint8List? _screenshotImage;

  Future<void> _captureScreenshot() async {
    try {
      final RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        setState(() {
          _screenshotImage = byteData.buffer.asUint8List();
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> setPhoto() async {
    await showModalBottomSheet<Map<String, dynamic>>(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: spaceCadet,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: const ChoosePhoto(cropImage: false));
      },
      context: context,
    ).then((dynamic value) async {
      if (value != null) {
        setState(() {
          isLocalBg = true;
          bgAvailable = null;
          bgLocal = value['bytes'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AigraphyWidget.createAppBar(context: context),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: AigraphyWidget.buttonGradient(
            context: context,
            input: 'Save',
            textColor: white,
            onPressed: () async {
              EasyLoading.show();
              await _captureScreenshot();
              if (_screenshotImage != null) {
                final imageFile = await createFileUploadDO(_screenshotImage!);
                final urlResult = await uploadFileDO(imageFile: imageFile);
                if (urlResult != null) {
                  await insertHistory(urlResult, context);
                  Navigator.of(context).pushNamed(Routes.combine_result,
                      arguments: CombineResult(urlResult: urlResult));
                } else
                  BotToast.showText(text: LocaleKeys.someThingWentWrong.tr());
              }
              EasyLoading.dismiss();
            }),
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _globalKey,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: isLocalBg == null
                        ? Image.asset(
                            bg_transparent,
                            fit: BoxFit.cover,
                          )
                        : isLocalBg!
                            ? Image.memory(
                                bgLocal!,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                bgAvailable!,
                                fit: BoxFit.cover,
                              ),
                  ),
                  Positioned(
                    left: position.dx,
                    top: position.dy,
                    child: Listener(
                      child: Container(
                        constraints: const BoxConstraints.expand(
                            width: 500, height: 500),
                        child: PhotoView(
                          minScale: PhotoViewComputedScale.contained * 0.3,
                          backgroundDecoration:
                              const BoxDecoration(color: Colors.transparent),
                          imageProvider: CachedNetworkImageProvider(
                            widget.url,
                          ),
                        ),
                      ),
                      onPointerDown: (details) {
                        setState(() {
                          position = Offset(
                            position.dx,
                            position.dy,
                          );
                        });
                      },
                      onPointerMove: (details) {
                        setState(() {
                          position = Offset(
                            position.dx + details.delta.dx,
                            position.dy + details.delta.dy,
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: ClickWidget(
                    function: setPhoto,
                    child: const Center(
                        child: DottedWidget(
                      size: 80,
                      sizeIcon: 24,
                    ))),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 80,
                  child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(right: 16),
                      itemBuilder: (context, index) => ClickWidget(
                            function: () {
                              setState(() {
                                isLocalBg = false;
                                bgAvailable = bgs[index];
                                bgLocal = null;
                              });
                            },
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  bgs[index],
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                )),
                          ),
                      separatorBuilder: (context, index) => const SizedBox(
                            width: 8,
                          ),
                      itemCount: bgs.length),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
