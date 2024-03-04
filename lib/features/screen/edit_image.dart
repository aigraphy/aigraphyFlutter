import 'dart:async';
import 'dart:math' as math;
import 'package:bot_toast/bot_toast.dart';
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:colorfilter_generator/presets.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hand_signature/signature.dart';
import 'package:image/image.dart' as img;
import 'package:image_editor_plus/data/image_item.dart';
import 'package:image_editor_plus/data/layer.dart';
import 'package:image_editor_plus/layers/background_blur_layer.dart';
import 'package:image_editor_plus/layers/image_layer.dart';
import 'package:image_editor_plus/loading_screen.dart';
import 'package:image_editor_plus/modules/colors_picker.dart';
import 'package:image_editor_plus/options.dart' as o;
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';

import '../../app/widget_support.dart';
import '../../common/bloc/user/bloc_user.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/error_code.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/helper_ads/ads_lovin_utils.dart';
import '../../common/models/request_model.dart';
import '../../common/route/routes.dart';
import '../../common/util/upload_image.dart';
import '../../common/widget/ads_applovin_banner.dart';
import '../../common/widget/animation_click.dart';
import '../../translations/export_lang.dart';
import '../widget/all_emojis_custom.dart';
import '../widget/background_layer_custom.dart';
import '../widget/emoji_layer_custom.dart';
import '../widget/gift_widget.dart';
import '../widget/not_enough_token.dart';
import '../widget/text_editor_image_custom.dart';
import '../widget/text_layer_custom.dart';
import 'price.dart';

late Size viewportSize;
double viewportRatio = 1;

List<Layer> layers = [], undoLayers = [], removedLayers = [];
Map<String, String> _translations = {};

String i18n(String sourceString) =>
    _translations[sourceString.toLowerCase()] ?? sourceString;

/// Single endpoint for MultiImageEditor & SingleImageEditor
class ImageEditor extends StatelessWidget {
  const ImageEditor({
    super.key,
    this.image,
    this.images,
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
  final List? images;
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
        images == null &&
        imagePickerOption?.captureFromCamera != true &&
        imagePickerOption?.pickFromGallery != true) {
      throw Exception(
          'No image to work with, provide an image or allow the image picker.');
    }

    if (image != null) {
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
    } else {
      return MultiImageEditor(
        images: images ?? [],
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
  }

  static void i18n(Map<String, String> translations) {
    translations.forEach((key, value) {
      _translations[key.toLowerCase()] = value;
    });
  }

  /// Set custom theme properties default is dark theme with white text
  static ThemeData theme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(
      background: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black87,
      iconTheme: IconThemeData(color: grey1100),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      toolbarTextStyle: TextStyle(color: grey1100),
      titleTextStyle: TextStyle(color: grey1100),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
    ),
    iconTheme: const IconThemeData(
      color: grey1100,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: grey1100),
    ),
  );
}

/// Show multiple image carousel to edit multple images at one and allow more images to be added
class MultiImageEditor extends StatefulWidget {
  const MultiImageEditor({
    super.key,
    this.images = const [],
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
  final List images;
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
  _MultiImageEditorState createState() => _MultiImageEditorState();
}

class _MultiImageEditorState extends State<MultiImageEditor> {
  List<ImageItem> images = [];

  @override
  void initState() {
    images = widget.images.map((e) => ImageItem(e)).toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    viewportSize = MediaQuery.of(context).size;

    return Theme(
      data: ImageEditor.theme,
      child: Scaffold(
        key: scaffoldGlobalKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            const BackButton(),
            const Spacer(),
            if (widget.imagePickerOption != null &&
                images.length < widget.imagePickerOption!.maxLength &&
                widget.imagePickerOption!.pickFromGallery)
              IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.photo),
                onPressed: () async {
                  final selected = await picker.pickMultiImage();

                  images.addAll(selected.map((e) => ImageItem(e)).toList());
                  setState(() {});
                },
              ),
            if (widget.imagePickerOption != null &&
                images.length < widget.imagePickerOption!.maxLength &&
                widget.imagePickerOption!.captureFromCamera)
              IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                icon: const Icon(Icons.camera_alt),
                onPressed: () async {
                  final selected =
                      await picker.pickImage(source: ImageSource.camera);

                  if (selected == null) {
                    return;
                  }

                  images.add(ImageItem(selected));
                  setState(() {});
                },
              ),
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: const Icon(Icons.check),
              onPressed: () async {
                Navigator.pop(context, images);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 332,
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 32),
                    for (var image in images)
                      Stack(children: [
                        GestureDetector(
                          onTap: () async {
                            final img = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SingleImageEditor(
                                  image: image,
                                ),
                              ),
                            );

                            if (img != null) {
                              image.load(img);
                              setState(() {});
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                                top: 32, right: 32, bottom: 32),
                            width: 200,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: grey1100.withAlpha(80)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.memory(
                                image.bytes,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 36,
                          right: 36,
                          child: Container(
                            height: 32,
                            width: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(60),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              iconSize: 20,
                              padding: const EdgeInsets.all(0),
                              onPressed: () {
                                images.remove(image);
                                setState(() {});
                              },
                              icon: const Icon(Icons.clear_outlined),
                            ),
                          ),
                        ),
                        if (widget.filtersOption != null)
                          Positioned(
                            bottom: 32,
                            left: 0,
                            child: Container(
                              height: 38,
                              width: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(100),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(19),
                                ),
                              ),
                              child: IconButton(
                                iconSize: 20,
                                padding: const EdgeInsets.all(0),
                                onPressed: () async {
                                  final Uint8List? editedImage =
                                      await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ImageFilters(
                                        image: image.bytes,
                                        options: widget.filtersOption,
                                      ),
                                    ),
                                  );

                                  if (editedImage != null) {
                                    image.load(editedImage);
                                  }

                                  setState(() {});
                                },
                                icon: const Icon(Icons.photo_filter_sharp),
                              ),
                            ),
                          ),
                      ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final picker = ImagePicker();
}

/// Image editor with all option available
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
  User firebaseUser = FirebaseAuth.instance.currentUser!;

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

  /// obtain image Uint8List by merging layers
  Future<Uint8List?> getMergedImage() async {
    if (layers.length == 1 && layers.first is BackgroundLayerData) {
      return (layers.first as BackgroundLayerData).image.bytes;
    } else if (layers.length == 1 && layers.first is ImageLayerData) {
      return (layers.first as ImageLayerData).image.bytes;
    }

    return screenshotController.capture(pixelRatio: pixelRatio);
  }

  Future<RequestModel?> uploadImage(Uint8List? res) async {
    RequestModel? request;
    String? url;
    final imageFile = await createFileUploadDO(res!);
    url = await uploadFile(imageFile: imageFile);
    if (url != null) {
      request = await insertRequest(url, context);
    }
    return request;
  }

  Future<void> saveImage() async {
    resetTransformation();
    final user = context.read<UserBloc>().userModel;
    if (user!.token < TOKEN_EDIT) {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return const NotEnoughToken();
        },
      );
      return;
    }
    EasyLoading.show();
    // showInterApplovin(context, () {}, seconds: 5);
    final binaryIntList =
        await screenshotController.capture(pixelRatio: pixelRatio);

    if (mounted) {
      final request = await uploadImage(binaryIntList);
      if (request != null) {
        context.read<UserBloc>().add(UpdateTokenUser(user.token - TOKEN_EDIT));
        final Map<String, dynamic> result = {
          'request': request,
          'uint8list': binaryIntList
        };
        FirebaseAnalytics.instance.logEvent(name: 'click_edit_image');
        Navigator.pop(context, result);
      } else {
        BotToast.showText(
            text: SOMETHING_WENT_WRONG, textStyle: body(color: grey1100));
      }
    }
    EasyLoading.dismiss();
  }

  @override
  void initState() {
    if (widget.image != null) {
      loadImage(widget.image!);
    }
    // checkHasAds();
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
        // Background layer
        if (layerItem is BackgroundLayerData) {
          return BackgroundLayerCustom(
            layerData: layerItem,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        // Image layer
        if (layerItem is ImageLayerData) {
          return ImageLayer(
            layerData: layerItem,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        // Background blur layer
        if (layerItem is BackgroundBlurLayerData && layerItem.radius > 0) {
          return BackgroundBlurLayer(
            layerData: layerItem,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        // Emoji layer
        if (layerItem is EmojiLayerData) {
          return EmojiLayer(
            layerData: layerItem,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        // Text layer
        if (layerItem is TextLayerData) {
          return TextLayerCustom(
            layerData: layerItem,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        // Blank layer
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
          icon: const Icon(
            Icons.arrow_back,
            size: 24,
            color: grey1100,
          ),
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
                IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: Icon(Icons.undo,
                      color: layers.length > 1 || removedLayers.isNotEmpty
                          ? grey1100
                          : Colors.grey),
                  onPressed: () {
                    if (removedLayers.isNotEmpty) {
                      layers.add(removedLayers.removeLast());
                      setState(() {});
                      return;
                    }

                    if (layers.length <= 1) {
                      return; // do not remove image layer
                    }

                    undoLayers.add(layers.removeLast());

                    setState(() {});
                  },
                ),
                IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: Icon(Icons.redo,
                      color: undoLayers.isNotEmpty ? grey1100 : Colors.grey),
                  onPressed: () {
                    if (undoLayers.isEmpty) {
                      return;
                    }

                    layers.add(undoLayers.removeLast());

                    setState(() {});
                  },
                ),
                if (widget.imagePickerOption?.pickFromGallery == true)
                  IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    icon: const Icon(Icons.photo),
                    onPressed: () async {
                      final image =
                          await picker.pickImage(source: ImageSource.gallery);

                      if (image == null) {
                        return;
                      }

                      loadImage(image);
                    },
                  ),
                if (widget.imagePickerOption?.captureFromCamera == true)
                  IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () async {
                      final image =
                          await picker.pickImage(source: ImageSource.camera);

                      if (image == null) {
                        return;
                      }

                      loadImage(image);
                    },
                  ),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: const GiftWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: GestureDetector(
            onScaleUpdate: (details) {
              // move
              if (details.pointerCount == 1) {
                x += details.focalPointDelta.dx;
                y += details.focalPointDelta.dy;
                setState(() {});
              }

              // scale
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
                    BottomButton(
                      icon: Icons.crop,
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
                  if (widget.brushOption != null) ...[
                    BottomButton(
                      icon: Icons.edit,
                      text: LocaleKeys.brush.tr(),
                      onTap: () async {
                        if (widget.brushOption!.translatable) {
                          final drawing = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageEditorDrawing(
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
                              builder: (context) => ImageEditorDrawing(
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
                  if (widget.textOption != null)
                    BottomButton(
                      icon: Icons.text_fields,
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
                  if (widget.flipOption != null)
                    BottomButton(
                      icon: Icons.flip,
                      text: LocaleKeys.flip.tr(),
                      onTap: () {
                        setState(() {
                          flipValue = flipValue == 0 ? math.pi : 0;
                        });
                      },
                    ),
                  if (widget.rotateOption != null)
                    BottomButton(
                      icon: Icons.rotate_left,
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
                    BottomButton(
                      icon: Icons.rotate_right,
                      text: LocaleKeys.rotateRight.tr(),
                      onTap: () {
                        final t = currentImage.width;
                        currentImage.width = currentImage.height;
                        currentImage.height = t;

                        rotateValue++;
                        setState(() {});
                      },
                    ),
                  if (widget.blurOption != null)
                    BottomButton(
                      icon: Icons.blur_on,
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
                                      color: grey100,
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
                                          style:
                                              const TextStyle(color: grey1100),
                                        )),
                                        const SizedBox(height: 20.0),
                                        Text(
                                          LocaleKeys.sliderColor.tr(),
                                          style:
                                              const TextStyle(color: grey1100),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(children: [
                                          Expanded(
                                            child: BarColorPicker(
                                              width: 300,
                                              thumbColor: grey1100,
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
                                          style:
                                              const TextStyle(color: grey1100),
                                        ),
                                        const SizedBox(height: 10.0),
                                        Row(children: [
                                          Expanded(
                                            child: Slider(
                                              activeColor: grey1100,
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
                                                  blurLayer.color = grey1100;
                                                });
                                              });
                                            },
                                          )
                                        ]),
                                        const SizedBox(height: 5.0),
                                        Text(
                                          LocaleKeys.colorOpacity.tr(),
                                          style:
                                              const TextStyle(color: grey1100),
                                        ),
                                        const SizedBox(height: 10.0),
                                        Row(children: [
                                          Expanded(
                                            child: Slider(
                                              activeColor: grey1100,
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
                  if (widget.filtersOption != null)
                    BottomButton(
                      icon: Icons.photo,
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

                        /// Use case, if you don't want your filter to effect your
                        /// other elements such as emoji and text. Use insert
                        /// instead of add like in line 888
                        //layers.insert(1, layer);
                        layers.add(layer);

                        await layer.image.loader.future;

                        setState(() {});
                      },
                    ),
                  if (widget.emojiOption != null)
                    BottomButton(
                      icon: FontAwesomeIcons.faceSmile,
                      text: LocaleKeys.emoji.tr(),
                      onTap: () async {
                        final EmojiLayerData? layer =
                            await showModalBottomSheet(
                          context: context,
                          backgroundColor: grey100,
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text:
                  '${formatToken(context).format(context.watch<UserBloc>().userModel!.token)} ${LocaleKeys.tokensRemaining.tr()} ',
              style: subhead(color: grey1100),
              children: <TextSpan>[
                TextSpan(
                  text: LocaleKeys.buyMore.tr(),
                  style: subhead(color: corn2),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.of(context)
                          .pushNamed(Routes.price, arguments: PriceScreen());
                    },
                )
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 24, right: 24, bottom: 16, top: 8),
            child: AppWidget.typeButtonGradientAfter(
                context: context,
                input: '${LocaleKeys.saveChange.tr()} -$TOKEN_EDIT',
                textColor: grey1100,
                icon: token,
                sizeAsset: 20,
                onPressed: saveImage),
          ),
          if (!isIOS) ...[
            const SizedBox(height: 16),
            const AdsApplovinBanner(),
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

/// Button used in bottomNavigationBar in ImageEditor
class BottomButton extends StatelessWidget {
  const BottomButton({
    super.key,
    this.onTap,
    this.onLongPress,
    required this.icon,
    required this.text,
  });
  final VoidCallback? onTap, onLongPress;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Icon(
              icon,
              color: grey1100,
            ),
            const SizedBox(height: 8),
            Text(
              i18n(text),
            ),
          ],
        ),
      ),
    );
  }
}

/// Crop given image with various aspect ratios
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
    if (_controller.currentState != null) {
      // _controller.currentState?.
    }
    return Scaffold(
      appBar: AppWidget.createSimpleAppBar(
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
          action: const Icon(Icons.check, size: 24, color: grey1100)),
      bottomNavigationBar: isIOS
          ? const SizedBox()
          : const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: AdsApplovinBanner(),
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
                lineColor: grey1000,
                cornerColor: grey1000,
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
                  AnimationClick(
                    function: () {
                      currentRatio = ratio.ratio;

                      setState(() {});
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            color:
                                currentRatio == ratio.ratio ? grey200 : grey100,
                            border: Border.all(color: grey200),
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        child: Text(i18n(ratio.title).toUpperCase(),
                            style: body(color: grey1100))),
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

/// Return filter applied Uint8List image
class ImageFilters extends StatefulWidget {
  const ImageFilters({
    super.key,
    required this.image,
    this.useCache = true,
    this.options,
  });
  final Uint8List image;

  /// apply each filter to given image in background and cache it to improve UX
  final bool useCache;
  final o.FiltersOption? options;

  @override
  _ImageFiltersState createState() => _ImageFiltersState();
}

class _ImageFiltersState extends State<ImageFilters> {
  late img.Image decodedImage;
  ColorFilterGenerator selectedFilter = PresetFilters.none;
  Uint8List resizedImage = Uint8List.fromList([]);
  double filterOpacity = 1;
  Uint8List? filterAppliedImage;
  ScreenshotController screenshotController = ScreenshotController();
  late List<ColorFilterGenerator> filters;

  @override
  void initState() {
    filters = [
      PresetFilters.none,
      ...widget.options?.filters ?? presetFiltersList.sublist(1)
    ];

    // decodedImage = img.decodeImage(widget.image)!;
    // resizedImage = img.copyResize(decodedImage, height: 64).getBytes();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            icon: const Icon(
              Icons.check,
              size: 24,
              color: grey1100,
            ),
            onPressed: () async {
              EasyLoading.show();
              // AdLovinUtils().showAdIfReady();
              final data = await screenshotController.capture();
              EasyLoading.dismiss();
              if (mounted) {
                Navigator.pop(context, data);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Screenshot(
          controller: screenshotController,
          child: Stack(
            children: [
              Image.memory(
                widget.image,
                fit: BoxFit.cover,
              ),
              FilterAppliedImage(
                key: Key('selectedFilter:${selectedFilter.name}'),
                image: widget.image,
                filter: selectedFilter,
                fit: BoxFit.cover,
                opacity: filterOpacity,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 160,
          child: Column(children: [
            SizedBox(
              height: 40,
              child: selectedFilter == PresetFilters.none
                  ? Container()
                  : selectedFilter.build(
                      Slider(
                        min: 0,
                        max: 1,
                        divisions: 100,
                        value: filterOpacity,
                        onChanged: (value) {
                          filterOpacity = value;
                          setState(() {});
                        },
                      ),
                    ),
            ),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (var filter in filters)
                    GestureDetector(
                      onTap: () {
                        selectedFilter = filter;
                        setState(() {});
                      },
                      child: Column(children: [
                        Container(
                          height: 64,
                          width: 64,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(48),
                            border: Border.all(
                              color: selectedFilter == filter
                                  ? grey1100
                                  : Colors.black,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(48),
                            child: FilterAppliedImage(
                              key: Key('filterPreviewButton:${filter.name}'),
                              image: widget.image,
                              filter: filter,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Text(
                          i18n(filter.name),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ]),
                    ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class FilterAppliedImage extends StatefulWidget {
  const FilterAppliedImage({
    super.key,
    required this.image,
    required this.filter,
    this.fit,
    this.onProcess,
    this.opacity = 1,
  });
  final Uint8List image;
  final ColorFilterGenerator filter;
  final BoxFit? fit;
  final Function(Uint8List)? onProcess;
  final double opacity;

  @override
  State<FilterAppliedImage> createState() => _FilterAppliedImageState();
}

class _FilterAppliedImageState extends State<FilterAppliedImage> {
  @override
  void initState() {
    super.initState();

    // process filter in background
    if (widget.onProcess != null) {
      // no filter supplied
      if (widget.filter.filters.isEmpty) {
        widget.onProcess!(widget.image);
        return;
      }

      final filterTask = img.Command();
      filterTask.decodeImage(widget.image);

      final matrix = widget.filter.matrix;

      filterTask.filter((image) {
        for (final pixel in image) {
          pixel.r = matrix[0] * pixel.r +
              matrix[1] * pixel.g +
              matrix[2] * pixel.b +
              matrix[3] * pixel.a +
              matrix[4];

          pixel.g = matrix[5] * pixel.r +
              matrix[6] * pixel.g +
              matrix[7] * pixel.b +
              matrix[8] * pixel.a +
              matrix[9];

          pixel.b = matrix[10] * pixel.r +
              matrix[11] * pixel.g +
              matrix[12] * pixel.b +
              matrix[13] * pixel.a +
              matrix[14];

          pixel.a = matrix[15] * pixel.r +
              matrix[16] * pixel.g +
              matrix[17] * pixel.b +
              matrix[18] * pixel.a +
              matrix[19];
        }

        return image;
      });

      filterTask.getBytesThread().then((result) {
        if (widget.onProcess != null && result != null) {
          widget.onProcess!(result);
        }
      }).catchError((err, stack) {
        print(err);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.filter.filters.isEmpty) {
      return Image.memory(
        widget.image,
        fit: widget.fit,
      );
    }

    return Opacity(
      opacity: widget.opacity,
      child: widget.filter.build(
        Image.memory(
          widget.image,
          fit: widget.fit,
        ),
      ),
    );
  }
}

/// Show image drawing surface over image
class ImageEditorDrawing extends StatefulWidget {
  const ImageEditorDrawing({
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
  State<ImageEditorDrawing> createState() => _ImageEditorDrawingState();
}

class _ImageEditorDrawingState extends State<ImageEditorDrawing> {
  Color pickerColor = grey1100,
      currentColor = grey1100,
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
                      color: grey200,
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
          icon: const Icon(
            Icons.clear,
            size: 24,
            color: grey1100,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        actions: [
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            icon: Icon(
              Icons.undo,
              color:
                  control.paths.isNotEmpty ? grey1100 : grey1100.withAlpha(80),
            ),
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
            icon: Icon(
              Icons.redo,
              color: undoList.isNotEmpty ? grey1100 : grey1100.withAlpha(80),
            ),
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
              color: grey1100,
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
              // AdLovinUtils().showAdIfReady();
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

/// Button used in bottomNavigationBar in ImageEditorDrawing
class ColorButton extends StatelessWidget {
  const ColorButton({
    super.key,
    required this.color,
    required this.onTap,
    this.isSelected = false,
  });
  final Color color;
  final Function(Color) onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap(color);
      },
      child: Container(
        height: 34,
        width: 34,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 23),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? grey1100 : Colors.white54,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}
