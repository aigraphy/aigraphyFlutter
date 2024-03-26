import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../translations/export_lang.dart';
import '../aigraphy_widget.dart';
import '../bloc/person/bloc_person.dart';
import '../config/config_color.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../util/upload_file_DO.dart';
import 'get_more_coin.dart';
import 'text_gradient.dart';

class RemBGImgLocal extends StatefulWidget {
  const RemBGImgLocal({super.key, required this.bytes, required this.ctx});
  final Uint8List bytes;
  final BuildContext ctx;
  @override
  State<RemBGImgLocal> createState() => _RemBGImgLocalState();
}

class _RemBGImgLocalState extends State<RemBGImgLocal> {
  List<Map<String, dynamic>> options = [];

  @override
  void initState() {
    super.initState();
    options = [
      {
        'title': LocaleKeys.humanAndAnimal.tr(),
        'option': null,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Image.asset(
              ic_removebg,
              width: 64,
              height: 64,
            ),
          ),
          Center(
            child: TextGradient(
              LocaleKeys.removeBackground.tr(),
              style: const TextStyle(
                  fontSize: 32,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'ClashGrotesk'),
              gradient: Theme.of(context).linerPimary,
            ),
          ),
          const SizedBox(height: 24),
          AigraphyWidget.buttonGradientAfter(
              context: context,
              input: '${LocaleKeys.removeNow.tr()} -$TOKEN_REMOVE_BG',
              onPressed: () async {
                final userModel = context.read<PersonBloc>().userModel!;
                if (userModel.coin < TOKEN_REMOVE_BG) {
                  showModalBottomSheet<void>(
                    context: context,
                    backgroundColor: spaceCadet,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10)),
                    ),
                    builder: (BuildContext context) {
                      return const GetMoreCoin();
                    },
                  );
                } else {
                  EasyLoading.show();
                  FirebaseAnalytics.instance.logEvent(name: 'click_remove_bg');
                  final imageFile = await createFileUploadDO(widget.bytes);
                  final link = await uploadFileDO(imageFile: imageFile);
                  if (link != null)
                    removeBGImgDevice(widget.ctx, link);
                  else
                    BotToast.showText(text: LocaleKeys.someThingWentWrong.tr());
                  Navigator.of(context).pop();
                }
              },
              icon: coin,
              sizeAsset: 20,
              textColor: white),
          const SizedBox(height: 24)
        ],
      ),
    );
  }
}
