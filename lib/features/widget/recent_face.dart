import 'dart:io';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_editor_plus/options.dart' as o;
import 'package:image_picker/image_picker.dart';

import '../../common/bloc/recent_face/bloc_recent_face.dart';
import '../../common/bloc/user/bloc_user.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/error_code.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/models/recent_face_model.dart';
import '../../common/widget/ads_applovin_banner.dart';
import '../../common/widget/animation_click.dart';
import '../../common/widget/animation_long_press.dart';
import '../../common/widget/gradient_text.dart';
import '../../common/widget/open_slot.dart';
import '../../translations/export_lang.dart';
import '../screen/crop_image.dart';
import 'list_photo.dart';
import 'loading_face.dart';

class RecentFace extends StatefulWidget {
  const RecentFace(
      {Key? key,
      required this.cropImage,
      this.handling = true,
      this.currentIndex = 0})
      : super(key: key);
  final bool cropImage;
  final bool handling;
  final int currentIndex;

  @override
  State<RecentFace> createState() => _RecentFaceState();
}

class _RecentFaceState extends State<RecentFace> {
  XFile? imageFile;
  late Uint8List imageSelected;
  bool showDelete = false;
  int _currentIndex = 0;

  Future<void> cropImage() async {
    final Uint8List? croppedImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageCropperFreeStyle(
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
      if (imageSelected.lengthInBytes / (1024 * 1024) >= 2) {
        BotToast.showText(
            text: LocaleKeys.pleaseChoosePhoto.tr(),
            textStyle: body(color: grey1100));
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
      backgroundColor: grey200,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: const ListPhoto(cropImage: true));
      },
      context: context,
    ).then((dynamic value) async {
      if (value != null) {
        Navigator.of(context).pop(value);
      }
    });
  }

  Widget itemRecent(int index, RecentFaceModel recentFaceModel) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        AnimationLongPress(
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
                    ? Border.all(color: grey1100, width: 2)
                    : null),
            child: LoadingFace(link: recentFaceModel.face),
          ),
        ),
        showDelete
            ? Positioned(
                right: -8,
                top: 6,
                child: AnimationClick(
                  function: () {
                    context.read<RecentFaceBloc>().add(
                        DeleteFace(recentFaceModel.id!, recentFaceModel.face));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        color: grey300),
                    child: Image.asset(
                      icClose,
                      width: 16,
                      height: 16,
                      color: grey1100,
                    ),
                  ),
                ))
            : const SizedBox()
      ],
    );
  }

  Widget recentWidget() {
    final recentsCount =
        context.watch<UserBloc>().userModel?.slotRecentFace ?? DEFAULT_SLOT;
    return BlocBuilder<RecentFaceBloc, RecentFaceState>(
        builder: (context, state) {
      if (state is RecentFaceLoaded) {
        final List<RecentFaceModel> recentFaces = state.recentFaces;
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
                  ? AnimationClick(
                      function: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const OpenSlot();
                          },
                        );
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        margin: const EdgeInsets.only(top: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: grey200,
                            border: Border.all(color: grey600),
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Image.asset(
                          lock,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : index > recentFaces.length - 1
                      ? Container(
                          width: 64,
                          height: 64,
                          alignment: Alignment.bottomCenter,
                          margin: const EdgeInsets.only(top: 16),
                          decoration: BoxDecoration(
                              color: grey200,
                              border: Border.all(color: grey600),
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
    final recents = context.read<RecentFaceBloc>().recentFaces;
    final userModel = context.read<UserBloc>().userModel!;
    if (recents.length >= userModel.slotRecentFace) {
      await showDialog(
        context: context,
        builder: (context) {
          return const OpenSlot();
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
              child: GradientText(
                LocaleKeys.chooseYourFaces.tr(),
                style: const TextStyle(
                    fontSize: 32,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'SpaceGrotesk'),
                gradient: Theme.of(context).linearGradientCustome,
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
              child: GradientText(
                LocaleKeys.orAddNewFace.tr(),
                style: const TextStyle(
                    fontSize: 22,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'SpaceGrotesk'),
                gradient: Theme.of(context).linearGradientCustome,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: AnimationClick(
                      function: () async {
                        await checkShowSlot();
                        takeAPhoto();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                            color: grey200,
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(icCamera,
                                width: 24, height: 24, color: grey1100),
                            const SizedBox(height: 16),
                            Text(
                              LocaleKeys.camera.tr(),
                              style: headline(color: grey1100),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: AnimationClick(
                      function: () async {
                        await checkShowSlot();
                        setPhoto();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                            color: grey200,
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(icPhoto,
                                width: 24, height: 24, color: grey1100),
                            const SizedBox(height: 16),
                            Text(
                              LocaleKeys.photos.tr(),
                              style: headline(color: grey1100),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (!isIOS) const Center(child: AdsApplovinBanner())
          ],
        ),
      ),
    );
  }
}
