import 'package:flutter/material.dart';

import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_image.dart';
import '../config_model/history_model.dart';
import '../config_router/name_router.dart';
import '../widget/choose_photo.dart';
import '../widget/click_widget.dart';
import 'editor_img.dart';
import 'res_edit_local_img.dart';

class Explored extends StatelessWidget {
  const Explored({super.key});

  Future<void> setPhoto(BuildContext context) async {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explored',
              style: style1(context: context),
            ),
            const SizedBox(height: 24),
            ClickWidget(
              function: () {
                setPhoto(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                    color: gray2, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(paint, width: 40, height: 40),
                    const SizedBox(height: 8),
                    Text(
                      'Edit Image',
                      style: style5(context: context),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
