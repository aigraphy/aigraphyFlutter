import 'dart:io';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_editor_plus/options.dart' as o;
import 'package:image_picker/image_picker.dart';

import '../../common/bloc/recent_face/bloc_recent_face.dart';
import '../../common/bloc/user/bloc_user.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/widget/ads_applovin_banner.dart';
import '../../common/widget/animation_click.dart';
import '../../common/widget/gradient_text.dart';
import '../../common/widget/open_slot.dart';
import '../../translations/export_lang.dart';
import '../screen/crop_image.dart';
import 'list_photo.dart';

class RecentFaceVideo extends StatefulWidget {
  const RecentFaceVideo({Key? key, required this.cropImage}) : super(key: key);
  final bool cropImage;

  @override
  State<RecentFaceVideo> createState() => _RecentFaceVideoState();
}

class _RecentFaceVideoState extends State<RecentFaceVideo> {
  XFile? imageFile;
  late Uint8List imageSelected;

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
      print(value);
      if (value != null) {
        Navigator.of(context).pop(value);
      }
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GradientText(
              LocaleKeys.addNewFace.tr(),
              style: const TextStyle(
                  fontSize: 32,
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
    );
  }
}
