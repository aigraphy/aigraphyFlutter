import 'dart:io';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_editor_plus/options.dart' as o;
import 'package:image_picker/image_picker.dart';

import '../../translations/export_lang.dart';
import '../bloc/face/bloc_face.dart';
import '../bloc/person/bloc_person.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../config_model/face_model.dart';
import '../screen/cropper_img.dart';
import '../widget_helper.dart';
import 'banner_ads.dart';
import 'buy_more_slot.dart';
import 'cached_face.dart';
import 'choose_photo.dart';
import 'click_long_press.dart';
import 'click_widget.dart';
import 'text_gradient.dart';

class ChooseFaces extends StatefulWidget {
  const ChooseFaces(
      {Key? key,
      required this.cropImage,
      this.handling = true,
      this.currentIndex = 0})
      : super(key: key);
  final bool cropImage;
  final bool handling;
  final int currentIndex;

  @override
  State<ChooseFaces> createState() => _ChooseFacesState();
}

class _ChooseFacesState extends State<ChooseFaces> {
  XFile? imageFile;
  late Uint8List imageSelected;
  bool showDelete = false;
  int _currentIndex = 0;

  Future<void> cropImage() async {
    final Uint8List? croppedImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CropperImg(
          image: imageSelected,
          availableRatios: const [
            o.AspectRatio(title: 'FREEDOM'),
          ],
        ),
      ),
    );
    if (croppedImage != null) {
      setState(() {
        imageSelected = croppedImage;
      });
    }
  }

  Future<void> takeAPhoto() async {
    imageFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 80);
    if (imageFile != null) {
      final File file = File(imageFile!.path);
      imageSelected = file.readAsBytesSync();
      if (imageSelected.lengthInBytes / (1024 * 1024) > 6) {
        BotToast.showText(
            text: LocaleKeys.pleaseChoosePhoto.tr(),
            textStyle: style7(color: white));
        Navigator.of(context).pop();
      } else {
        if (widget.cropImage) {
          await cropImage();
        }
        final Map<String, dynamic> res = {
          'bytes': imageSelected,
          'path': file.path
        };
        Navigator.of(context).pop(res);
      }
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
            child: ChoosePhoto(cropImage: widget.cropImage));
      },
      context: context,
    ).then((dynamic value) async {
      if (value != null) {
        Navigator.of(context).pop(value);
      }
    });
  }

  Widget itemRecent(int index, FaceModel recentFaceModel) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        ClickLongPress(
          function: () {
            setState(() {
              showDelete = !showDelete;
            });
          },
          onTap: () async {
            setState(() {
              _currentIndex = index;
            });
            Map<String, dynamic> res = {};
            EasyLoading.show();
            if (widget.handling) {
              try {
                final image = await getImage(recentFaceModel.face);
                final tempDir = await Directory.systemTemp.createTemp();
                final tempFile = File(
                    '${tempDir.path}/${DateTime.now().toIso8601String()}.jpg');
                await tempFile.writeAsBytes(image);
                res = {
                  'bytes': image,
                  'path': tempFile.path,
                  'has_update_face': false
                };
              } catch (e) {
                BotToast.showText(text: SOMETHING_WENT_WRONG);
              }
            } else {
              res = {'index': _currentIndex, 'has_update_face': false};
            }
            EasyLoading.dismiss();

            Navigator.of(context).pop(res);
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: _currentIndex == index
                    ? Border.all(color: white, width: 2)
                    : null),
            child: CachedFace(link: recentFaceModel.face),
          ),
        ),
        showDelete
            ? Positioned(
                right: -8,
                top: 6,
                child: ClickWidget(
                  function: () {
                    context.read<FaceBloc>().add(
                        DeleteFace(recentFaceModel.id!, recentFaceModel.face));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        color: blackCoral),
                    child: Image.asset(
                      icClose,
                      width: 16,
                      height: 16,
                      color: white,
                    ),
                  ),
                ))
            : const SizedBox()
      ],
    );
  }

  Widget recentWidget() {
    final recentsCount =
        context.watch<PersonBloc>().userModel?.slotRecentFace ?? DEFAULT_SLOT;
    return BlocBuilder<FaceBloc, FaceState>(builder: (context, state) {
      if (state is FaceLoaded) {
        final List<FaceModel> recentFaces = state.recentFaces;
        return Align(
          alignment: Alignment.centerLeft,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemCount: recentFaces.length >= recentsCount
                ? recentsCount + 1
                : recentsCount,
            itemBuilder: (context, index) {
              return index >= recentsCount
                  ? ClickWidget(
                      function: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const BuyMoreSlot();
                          },
                        );
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        margin: const EdgeInsets.only(top: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: spaceCadet,
                            border: Border.all(color: isabelline),
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Image.asset(ic_open_slot,
                            fit: BoxFit.cover, color: cultured),
                      ),
                    )
                  : index > recentFaces.length - 1
                      ? Container(
                          width: 64,
                          height: 64,
                          alignment: Alignment.bottomCenter,
                          margin: const EdgeInsets.only(top: 16),
                          decoration: BoxDecoration(
                              color: spaceCadet,
                              border: Border.all(color: isabelline),
                              borderRadius: BorderRadius.circular(10)),
                        )
                      : itemRecent(index, recentFaces[index]);
            },
          ),
        );
      }
      return const Center(child: CupertinoActivityIndicator());
    });
  }

  Future<void> checkShowSlot() async {
    final recents = context.read<FaceBloc>().recentFaces;
    final userModel = context.read<PersonBloc>().userModel!;
    if (recents.length >= userModel.slotRecentFace) {
      await showDialog(
        context: context,
        builder: (context) {
          return const BuyMoreSlot();
        },
      );
    }
  }

  @override
  void initState() {
    _currentIndex = widget.currentIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (tap) {
        setState(() {
          showDelete = false;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextGradient(
                LocaleKeys.chooseYourFaces.tr(),
                style: const TextStyle(
                    fontSize: 32,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'ClashGrotesk'),
                gradient: Theme.of(context).linerPimary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: recentWidget(),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AigraphyWidget.typeButtonGradient(
                  context: context,
                  icon: ic_add_face,
                  sizeAsset: 24,
                  input: LocaleKeys.addNewFace.tr(),
                  onPressed: () async {
                    await checkShowSlot();
                    setPhoto();
                  },
                  textColor: white),
            ),
            const SizedBox(height: 16),
            if (!isIOS) const Center(child: BannerAds())
          ],
        ),
      ),
    );
  }
}
