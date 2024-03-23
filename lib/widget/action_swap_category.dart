import 'package:flutter/material.dart';
import 'package:image_editor_plus/image_editor_plus.dart';

import '../config/config_color.dart';
import '../config/config_image.dart';
import '../config_model/history_model.dart';
import '../config_router/name_router.dart';
import '../screen/res_edit_local_img.dart';
import '../widget_helper.dart';
import 'choose_photo.dart';
import 'rem_bg_img_local.dart';

class ActionSwapCategory extends StatelessWidget {
  const ActionSwapCategory({super.key});

  void showRemoveBg(BuildContext context, String path) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: spaceCadet,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (BuildContext ctx) {
        return RemBGImgLocal(path: path, ctx: context);
      },
    );
  }

  Future<void> setPhoto(BuildContext context, bool removeBg) async {
    await showModalBottomSheet<Map<String, dynamic>>(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: spaceCadet,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: const ChoosePhoto());
      },
      context: context,
    ).then((value) async {
      if (value != null) {
        if (removeBg) {
          showRemoveBg(context, value['path']);
        } else {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleImageEditor(image: value['bytes']),
            ),
          );
          if (res != null) {
            final request = res['request'] as HistoryModel;
            Navigator.of(context).pushNamed(Routes.res_edit_local_img,
                arguments: ResEditLocalImg(
                    imageEdit: request.imageRes, requestId: request.id!));
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: AigraphyWidget.typeButtonStartAction2(
                context: context,
                input: 'Remove BG',
                vertical: 20,
                icon: ic_removebg,
                onPressed: () {
                  setPhoto(context, true);
                },
                bgColor: black,
                sizeAsset: 24,
                borderColor: blackCoral,
                textColor: white),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: AigraphyWidget.typeButtonStartAction2(
                context: context,
                input: 'Edit Image',
                vertical: 20,
                icon: paint,
                onPressed: () {
                  setPhoto(context, false);
                },
                bgColor: black,
                sizeAsset: 24,
                colorAsset: white,
                borderColor: blackCoral,
                textColor: white),
          )
        ],
      ),
    );
  }
}
