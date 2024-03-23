import 'dart:async';
import 'dart:math' as math;

import 'package:bot_toast/bot_toast.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image/image.dart' as img;
import 'package:image_editor_plus/data/image_item.dart';
import 'package:image_editor_plus/data/layer.dart';
import 'package:image_editor_plus/layers/background_blur_layer.dart';
import 'package:image_editor_plus/layers/background_layer.dart';
import 'package:image_editor_plus/layers/emoji_layer.dart';
import 'package:image_editor_plus/layers/image_layer.dart';
import 'package:image_editor_plus/layers/text_layer.dart';
import 'package:image_editor_plus/loading_screen.dart';
import 'package:image_editor_plus/modules/all_emojies.dart';
import 'package:image_editor_plus/modules/colors_picker.dart';
import 'package:image_editor_plus/modules/text.dart';
import 'package:image_editor_plus/options.dart' as o;
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';

import '../../translations/export_lang.dart';
import '../aigraphy_widget.dart';
import '../bloc/person/bloc_person.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../config_model/history_model.dart';
import '../config_router/name_router.dart';
import '../util/upload_file_DO.dart';
import '../widget/banner_ads.dart';
import '../widget/button_option.dart';
import '../widget/click_widget.dart';
import '../widget/get_more_coin.dart';
import '../widget/image_brush.dart';
import '../widget/image_filter.dart';
import '../widget/offer_first_time.dart';
import 'in_app_purchase.dart';

late Size viewportSize;
double viewportRatio = 1;

List<Layer> layers = [], undoLayers = [], removedLayers = [];
Map<String, String> _translations = {};

String i18n(String sourceString) =>
    _translations[sourceString.toLowerCase()] ?? sourceString;

class EditorImg extends StatelessWidget {
  const EditorImg({
    super.key,
    this.image,
    this.savePath,
    this.imagePickerOption,
    this.cropOption = const o.CropOption(),
    this.blurOption = const o.BlurOption(),
    this.brushOption = const o.BrushOption(),
    this.emojiOption = const o.EmojiOption(),
    this.filtersOption = const o.FiltersOption(),
    this.flipOption = const o.FlipOption(),
    this.rotateOption = const o.RotateOption(),
    this.textOption = const o.TextOption(),
  });
  final dynamic image;
  final String? savePath;

  final o.ImagePickerOption? imagePickerOption;
  final o.CropOption? cropOption;
  final o.BlurOption? blurOption;
  final o.BrushOption? brushOption;
  final o.EmojiOption? emojiOption;
  final o.FiltersOption? filtersOption;
  final o.FlipOption? flipOption;
  final o.RotateOption? rotateOption;
  final o.TextOption? textOption;

  @override
  Widget build(BuildContext context) {
    if (image == null &&
        imagePickerOption?.captureFromCamera != true &&
        imagePickerOption?.pickFromGallery != true) {
      throw Exception(
          'No image to work with, provide an image or allow the image picker.');
    }

    return SingleImageEditor(
      image: image,
      savePath: savePath,
      imagePickerOption: imagePickerOption,
      cropOption: cropOption,
      blurOption: blurOption,
      brushOption: brushOption,
      emojiOption: emojiOption,
      filtersOption: filtersOption,
      flipOption: flipOption,
      rotateOption: rotateOption,
      textOption: textOption,
    );
  }

  static void i18n(Map<String, String> translations) {
    translations.forEach((key, value) {
      _translations[key.toLowerCase()] = value;
    });
  }

  static ThemeData theme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(
      background: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black87,
      iconTheme: IconThemeData(color: white),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      toolbarTextStyle: TextStyle(color: white),
      titleTextStyle: TextStyle(color: white),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
    ),
    iconTheme: const IconThemeData(
      color: white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: white),
    ),
  );
}

class SingleImageEditor extends StatefulWidget {
  const SingleImageEditor({
    super.key,
    this.image,
    this.savePath,
    this.imagePickerOption,
    this.cropOption = const o.CropOption(),
    this.blurOption = const o.BlurOption(),
    this.brushOption = const o.BrushOption(),
    this.emojiOption = const o.EmojiOption(),
    this.filtersOption = const o.FiltersOption(),
    this.flipOption = const o.FlipOption(),
    this.rotateOption = const o.RotateOption(),
    this.textOption = const o.TextOption(),
  });
  final dynamic image;
  final String? savePath;

  final o.ImagePickerOption? imagePickerOption;
  final o.CropOption? cropOption;
  final o.BlurOption? blurOption;
  final o.BrushOption? brushOption;
  final o.EmojiOption? emojiOption;
  final o.FiltersOption? filtersOption;
  final o.FlipOption? flipOption;
  final o.RotateOption? rotateOption;
  final o.TextOption? textOption;

  @override
  _SingleImageEditorState createState() => _SingleImageEditorState();
}

class _SingleImageEditorState extends State<SingleImageEditor> {
  ImageItem currentImage = ImageItem();
  User userFB = FirebaseAuth.instance.currentUser!;

  ScreenshotController screenshotController = ScreenshotController();

  double flipValue = 0;
  int rotateValue = 0;

  double x = 0;
  double y = 0;
  double z = 0;

  double lastScaleFactor = 1, scaleFactor = 1;
  double widthRatio = 1, heightRatio = 1, pixelRatio = 1;

  void resetTransformation() {
    scaleFactor = 1;
    x = 0;
    y = 0;
    setState(() {});
  }

  Future<Uint8List?> getMergedImage() async {
    if (layers.length == 1 && layers.first is BackgroundLayerData) {
      return (layers.first as BackgroundLayerData).image.bytes;
    } else if (layers.length == 1 && layers.first is ImageLayerData) {
      return (layers.first as ImageLayerData).image.bytes;
    }

    return screenshotController.capture(pixelRatio: pixelRatio);
  }

  Future<HistoryModel?> uploadImage(Uint8List? res) async {
    HistoryModel? request;
    String? url;
    final imageFile = await createFileUploadDO(res!);
    url = await uploadFileDO(imageFile: imageFile);
    if (url != null) {
      request = await insertRequest(url, context);
    }
    return request;
  }

  Future<void> saveImage() async {
    resetTransformation();
    final user = context.read<PersonBloc>().userModel;
    if (user!.coin < TOKEN_EDIT) {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: spaceCadet,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(10), topLeft: Radius.circular(10)),
        ),
        builder: (BuildContext context) {
          return const GetMoreCoin();
        },
      );
      return;
    }
    EasyLoading.show();
    final binaryIntList =
        await screenshotController.capture(pixelRatio: pixelRatio);

    if (mounted) {
      final request = await uploadImage(binaryIntList);
      if (request != null) {
        context.read<PersonBloc>().add(UpdateCoinUser(user.coin - TOKEN_EDIT));
        final Map<String, dynamic> result = {
          'request': request,
          'uint8list': binaryIntList
        };
        FirebaseAnalytics.instance.logEvent(name: 'click_edit_image');
        Navigator.pop(context, result);
      } else {
        BotToast.showText(
            text: SOMETHING_WENT_WRONG, textStyle: style7(color: white));
      }
    }
    EasyLoading.dismiss();
  }

  @override
  void initState() {
    if (widget.image != null) {
      loadImage(widget.image!);
    }
    super.initState();
  }

  @override
  void dispose() {
    layers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    viewportSize = MediaQuery.of(context).size;
    pixelRatio = MediaQuery.of(context).devicePixelRatio;

    final layersStack = Stack(
      children: layers.map((layerItem) {
        if (layerItem is BackgroundLayerData) {
          return BackgroundLayer(
            layerData: layerItem,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        if (layerItem is ImageLayerData) {
          return ImageLayer(
            layerData: layerItem,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        if (layerItem is BackgroundBlurLayerData && layerItem.radius > 0) {
          return BackgroundBlurLayer(
            layerData: layerItem,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        if (layerItem is EmojiLayerData) {
          return EmojiLayer(
            layerData: layerItem,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        if (layerItem is TextLayerData) {
          return TextLayer(
            layerData: layerItem,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        return Container();
      }).toList(),
    );

    widthRatio = currentImage.width / viewportSize.width;
    heightRatio = currentImage.height / viewportSize.height;
    pixelRatio = math.max(heightRatio, widthRatio);

    return Scaffold(
      key: scaffoldGlobalKey,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Image.asset(arrowLeft, width: 24, height: 24, color: white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          SizedBox(
            width: MediaQuery.of(context).size.width - 48,
            child: SingleChildScrollView(
              reverse: true,
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                ClickWidget(
                    function: () {
                      if (removedLayers.isNotEmpty) {
                        layers.add(removedLayers.removeLast());
                        setState(() {});
                        return;
                      }

                      if (layers.length <= 1) {
                        return;
                      }

                      undoLayers.add(layers.removeLast());

                      setState(() {});
                    },
                    child: Image.asset(ic_undo,
                        width: 24,
                        height: 24,
                        color: layers.length > 1 || removedLayers.isNotEmpty
                            ? white
                            : gray)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ClickWidget(
                      function: () {
                        if (undoLayers.isEmpty) {
                          return;
                        }

                        layers.add(undoLayers.removeLast());

                        setState(() {});
                      },
                      child: Image.asset(ic_redo,
                          width: 24,
                          height: 24,
                          color: undoLayers.isNotEmpty ? white : gray)),
                ),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: const OfferFirstTime(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: GestureDetector(
            onScaleUpdate: (details) {
              if (details.pointerCount == 1) {
                x += details.focalPointDelta.dx;
                y += details.focalPointDelta.dy;
                setState(() {});
              }

              if (details.pointerCount == 2) {
                if (details.horizontalScale >= 1) {
                  scaleFactor = lastScaleFactor *
                      math.min(details.horizontalScale, details.verticalScale);
                  setState(() {});
                }
              }
            },
            onScaleEnd: (details) {
              lastScaleFactor = scaleFactor;
            },
            child: SizedBox(
              height: currentImage.height / pixelRatio,
              width: currentImage.width / pixelRatio,
              child: Center(
                child: Screenshot(
                  controller: screenshotController,
                  child: RotatedBox(
                    quarterTurns: rotateValue,
                    child: Transform(
                      transform: Matrix4.rotationY(flipValue),
                      alignment: FractionalOffset.center,
                      child: layersStack,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (widget.cropOption != null)
                    ButtonOption(
                      icon: ic_crop,
                      text: LocaleKeys.crop.tr(),
                      onTap: () async {
                        resetTransformation();
                        LoadingScreen(scaffoldGlobalKey).show();
                        final mergedImage = await getMergedImage();
                        LoadingScreen(scaffoldGlobalKey).hide();

                        if (!mounted) {
                          return;
                        }

                        final Uint8List? croppedImage = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageCropper(
                              image: mergedImage!,
                              availableRatios: const [
                                o.AspectRatio(title: 'FREEDOM'),
                                o.AspectRatio(title: '1:1', ratio: 1),
                                o.AspectRatio(title: '1:2', ratio: 1 / 2),
                                o.AspectRatio(title: '2:3', ratio: 2 / 3),
                                o.AspectRatio(title: '4:3', ratio: 4 / 3),
                                o.AspectRatio(title: '5:4', ratio: 5 / 4),
                                o.AspectRatio(title: '7:5', ratio: 7 / 5),
                                o.AspectRatio(title: '16:9', ratio: 16 / 9),
                              ],
                            ),
                          ),
                        );

                        if (croppedImage == null) {
                          return;
                        }

                        flipValue = 0;
                        rotateValue = 0;

                        await currentImage.load(croppedImage);

                        setState(() {});
                      },
                    ),
                  if (widget.flipOption != null)
                    ButtonOption(
                      icon: ic_flip,
                      text: LocaleKeys.flip.tr(),
                      onTap: () {
                        setState(() {
                          flipValue = flipValue == 0 ? math.pi : 0;
                        });
                      },
                    ),
                  if (widget.rotateOption != null)
                    ButtonOption(
                      icon: ic_rotate_left,
                      text: LocaleKeys.rotateLeft.tr(),
                      onTap: () {
                        final t = currentImage.width;
                        currentImage.width = currentImage.height;
                        currentImage.height = t;

                        rotateValue--;
                        setState(() {});
                      },
                    ),
                  if (widget.rotateOption != null)
                    ButtonOption(
                      icon: ic_rotate_right,
                      text: LocaleKeys.rotateRight.tr(),
                      onTap: () {
                        final t = currentImage.width;
                        currentImage.width = currentImage.height;
                        currentImage.height = t;

                        rotateValue++;
                        setState(() {});
                      },
                    ),
                  if (widget.brushOption != null) ...[
                    ButtonOption(
                      icon: ic_brush,
                      text: LocaleKeys.brush.tr(),
                      onTap: () async {
                        if (widget.brushOption!.translatable) {
                          final drawing = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageBrush(
                                image: currentImage,
                                options: widget.brushOption!,
                              ),
                            ),
                          );

                          if (drawing != null) {
                            undoLayers.clear();
                            removedLayers.clear();

                            layers.add(
                              ImageLayerData(
                                image: ImageItem(drawing),
                                offset: Offset(
                                  -currentImage.width / 4,
                                  -currentImage.height / 4,
                                ),
                              ),
                            );

                            setState(() {});
                          }
                        } else {
                          resetTransformation();
                          LoadingScreen(scaffoldGlobalKey).show();
                          final mergedImage = await getMergedImage();
                          LoadingScreen(scaffoldGlobalKey).hide();

                          if (!mounted) {
                            return;
                          }

                          final drawing = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageBrush(
                                image: ImageItem(mergedImage!),
                                options: widget.brushOption!,
                              ),
                            ),
                          );

                          if (drawing != null) {
                            currentImage.load(drawing);

                            setState(() {});
                          }
                        }
                      },
                    )
                  ],
                  if (widget.blurOption != null)
                    ButtonOption(
                      icon: ic_blur,
                      text: LocaleKeys.blur.tr(),
                      onTap: () {
                        final blurLayer = BackgroundBlurLayerData(
                          color: Colors.transparent,
                          radius: 0.0,
                          opacity: 0.0,
                        );

                        undoLayers.clear();
                        removedLayers.clear();
                        layers.add(blurLayer);
                        setState(() {});

                        showModalBottomSheet(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                topLeft: Radius.circular(10)),
                          ),
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setS) {
                                return SingleChildScrollView(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: black,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          topLeft: Radius.circular(10)),
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    height: 400,
                                    child: Column(
                                      children: [
                                        Center(
                                            child: Text(
                                          LocaleKeys.sliderFilterColor.tr(),
                                          style: const TextStyle(color: white),
                                        )),
                                        const SizedBox(height: 20.0),
                                        Text(
                                          LocaleKeys.sliderColor.tr(),
                                          style: const TextStyle(color: white),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(children: [
                                          Expanded(
                                            child: BarColorPicker(
                                              width: 300,
                                              thumbColor: white,
                                              cornerRadius: 10,
                                              pickMode: PickMode.color,
                                              colorListener: (int value) {
                                                setS(() {
                                                  setState(() {
                                                    blurLayer.color =
                                                        Color(value);
                                                  });
                                                });
                                              },
                                            ),
                                          ),
                                          TextButton(
                                            child: Text(
                                              LocaleKeys.reset.tr(),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                setS(() {
                                                  blurLayer.color =
                                                      Colors.transparent;
                                                });
                                              });
                                            },
                                          )
                                        ]),
                                        const SizedBox(height: 5.0),
                                        Text(
                                          LocaleKeys.blurRadius.tr(),
                                          style: const TextStyle(color: white),
                                        ),
                                        const SizedBox(height: 10.0),
                                        Row(children: [
                                          Expanded(
                                            child: Slider(
                                              activeColor: white,
                                              inactiveColor: Colors.grey,
                                              value: blurLayer.radius,
                                              min: 0.0,
                                              max: 10.0,
                                              onChanged: (v) {
                                                setS(() {
                                                  setState(() {
                                                    blurLayer.radius = v;
                                                  });
                                                });
                                              },
                                            ),
                                          ),
                                          TextButton(
                                            child: Text(
                                              LocaleKeys.reset.tr(),
                                            ),
                                            onPressed: () {
                                              setS(() {
                                                setState(() {
                                                  blurLayer.color = white;
                                                });
                                              });
                                            },
                                          )
                                        ]),
                                        const SizedBox(height: 5.0),
                                        Text(
                                          LocaleKeys.colorOpacity.tr(),
                                          style: const TextStyle(color: white),
                                        ),
                                        const SizedBox(height: 10.0),
                                        Row(children: [
                                          Expanded(
                                            child: Slider(
                                              activeColor: white,
                                              inactiveColor: Colors.grey,
                                              value: blurLayer.opacity,
                                              min: 0.00,
                                              max: 1.0,
                                              onChanged: (v) {
                                                setS(() {
                                                  setState(() {
                                                    blurLayer.opacity = v;
                                                  });
                                                });
                                              },
                                            ),
                                          ),
                                          TextButton(
                                            child: Text(
                                              LocaleKeys.reset.tr(),
                                            ),
                                            onPressed: () {
                                              setS(() {
                                                setState(() {
                                                  blurLayer.opacity = 0.0;
                                                });
                                              });
                                            },
                                          )
                                        ]),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  if (widget.textOption != null)
                    ButtonOption(
                      icon: ic_text,
                      text: LocaleKeys.text.tr(),
                      onTap: () async {
                        final TextLayerData? layer = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TextEditorImage(),
                          ),
                        );

                        if (layer == null) {
                          return;
                        }

                        undoLayers.clear();
                        removedLayers.clear();

                        layers.add(layer);

                        setState(() {});
                      },
                    ),
                  if (widget.emojiOption != null)
                    ButtonOption(
                      icon: ic_emoji,
                      text: LocaleKeys.emoji.tr(),
                      onTap: () async {
                        final EmojiLayerData? layer =
                            await showModalBottomSheet(
                          context: context,
                          backgroundColor: black,
                          builder: (BuildContext context) {
                            return const Emojies();
                          },
                        );

                        if (layer == null) {
                          return;
                        }

                        undoLayers.clear();
                        removedLayers.clear();
                        layers.add(layer);

                        setState(() {});
                      },
                    ),
                  if (widget.filtersOption != null)
                    ButtonOption(
                      icon: ic_filter,
                      text: LocaleKeys.filter.tr(),
                      onTap: () async {
                        resetTransformation();

                        LoadingScreen(scaffoldGlobalKey).show();
                        final mergedImage = await getMergedImage();
                        LoadingScreen(scaffoldGlobalKey).hide();

                        if (!mounted) {
                          return;
                        }

                        final Uint8List? filterAppliedImage =
                            await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageFilters(
                              image: mergedImage!,
                              options: widget.filtersOption,
                            ),
                          ),
                        );

                        if (filterAppliedImage == null) {
                          return;
                        }

                        removedLayers.clear();
                        undoLayers.clear();

                        final layer = BackgroundLayerData(
                          image: ImageItem(filterAppliedImage),
                        );

                        layers.add(layer);

                        await layer.image.loader.future;

                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text:
                  '${formatCoin(context).format(context.watch<PersonBloc>().userModel!.coin)} ${LocaleKeys.coinsRemaining.tr()} ',
              style: style9(color: white),
              children: <TextSpan>[
                TextSpan(
                  text: LocaleKeys.buyMore.tr(),
                  style: style9(color: yellow2),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.of(context).pushNamed(Routes.in_app_purchase,
                          arguments: InAppPurchase());
                    },
                )
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 24, right: 24, bottom: 16, top: 8),
            child: AigraphyWidget.typeButtonGradientAfter(
                context: context,
                input: '${LocaleKeys.saveChange.tr()} -$TOKEN_EDIT',
                textColor: white,
                icon: coin,
                sizeAsset: 20,
                onPressed: saveImage),
          ),
          if (!isIOS) ...[
            const SizedBox(height: 16),
            const BannerAds(),
          ],
        ],
      ),
    );
  }

  final picker = ImagePicker();

  Future<void> loadImage(dynamic imageFile) async {
    await currentImage.load(imageFile);

    layers.clear();

    layers.add(BackgroundLayerData(
      image: currentImage,
    ));

    setState(() {});
  }
}

class ImageCropper extends StatefulWidget {
  const ImageCropper({
    super.key,
    required this.image,
    this.availableRatios = const [
      o.AspectRatio(title: 'FREEDOM'),
      o.AspectRatio(title: '1:1', ratio: 1),
      o.AspectRatio(title: '1:2', ratio: 1 / 2),
      o.AspectRatio(title: '1:3', ratio: 1 / 3),
      o.AspectRatio(title: '4:3', ratio: 4 / 3),
      o.AspectRatio(title: '5:4', ratio: 5 / 4),
      o.AspectRatio(title: '7:5', ratio: 7 / 5),
      o.AspectRatio(title: '16:9', ratio: 16 / 9),
    ],
  });
  final Uint8List image;
  final List<o.AspectRatio> availableRatios;

  @override
  _ImageCropperState createState() => _ImageCropperState();
}

class _ImageCropperState extends State<ImageCropper> {
  final GlobalKey<ExtendedImageEditorState> _controller =
      GlobalKey<ExtendedImageEditorState>();

  double? currentRatio;
  bool isLandscape = true;
  int rotateAngle = 0;

  double? get aspectRatio => currentRatio == null
      ? null
      : isLandscape
          ? currentRatio!
          : (1 / currentRatio!);

  @override
  void initState() {
    if (widget.availableRatios.isNotEmpty) {
      currentRatio = widget.availableRatios.first.ratio;
    }
    _controller.currentState?.rotate(right: true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.currentState != null) {}
    return Scaffold(
      appBar: AigraphyWidget.createSimpleAppBar(
          context: context,
          onTap: () async {
            final state = _controller.currentState;

            if (state == null || state.getCropRect() == null) {
              Navigator.pop(context);
            }

            final data = await cropImageWithThread(
              imageBytes: state!.rawImageData,
              rect: state.getCropRect()!,
            );

            if (mounted) {
              Navigator.pop(context, data);
            }
          },
          action: const Icon(Icons.check, size: 24, color: white)),
      bottomNavigationBar: isIOS
          ? const SizedBox()
          : const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: BannerAds(),
            ),
      body: Column(
        children: [
          Expanded(
            child: ExtendedImage.memory(
              widget.image,
              cacheRawData: true,
              fit: BoxFit.contain,
              extendedImageEditorKey: _controller,
              mode: ExtendedImageMode.editor,
              initEditorConfigHandler: (_) => EditorConfig(
                lineColor: gray1000,
                cornerColor: gray1000,
                cropAspectRatio: aspectRatio,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 12,
              spacing: 12,
              children: <Widget>[
                for (var ratio in widget.availableRatios)
                  ClickWidget(
                    function: () {
                      currentRatio = ratio.ratio;

                      setState(() {});
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            color: currentRatio == ratio.ratio
                                ? spaceCadet
                                : black,
                            border: Border.all(color: spaceCadet),
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: Text(i18n(ratio.title).toUpperCase(),
                            style: style7(color: white))),
                  )
              ],
            ),
          ),
          const SizedBox(height: 24)
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
