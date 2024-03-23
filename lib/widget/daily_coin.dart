import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../translations/export_lang.dart';
import '../aigraphy_widget.dart';
import '../bloc/person/bloc_person.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../config_model/person_model.dart';
import 'text_gradient.dart';

class DailyCoin extends StatelessWidget {
  const DailyCoin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(icon_star, width: 120),
              Positioned(
                  right: -65,
                  top: 26,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(right: 24),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: yellow1,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            coin,
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            '+$TOKEN_DAILY',
                            style: style6(color: black),
                          ),
                        ],
                      ),
                    ),
                  ))
            ],
          ),
          const SizedBox(height: 24),
          DefaultTextStyle(
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 30,
                height: 1,
                fontWeight: FontWeight.w700,
                fontFamily: 'ClashGrotesk'),
            child: TextGradient(
              LocaleKeys.checkInAnd.tr(),
              gradient: Theme.of(context).linerPimary,
            ),
          ),
          const SizedBox(height: 8),
          DefaultTextStyle(
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 30,
                height: 1,
                fontWeight: FontWeight.w700,
                fontFamily: 'ClashGrotesk'),
            child: TextGradient(
              LocaleKeys.getCoins.tr(),
              gradient: Theme.of(context).linerPimary,
            ),
          ),
          const SizedBox(height: 16),
          AigraphyWidget.typeButtonGradient(
              context: context,
              input: LocaleKeys.checkInNow.tr(),
              vertical: 16,
              onPressed: () async {
                final PersonModel? user = context.read<PersonBloc>().userModel;
                if (user != null) {
                  EasyLoading.show();
                  final timeNow = await getTime();
                  if (canCheckIn(user.dateCheckIn, timeNow)) {
                    context.read<PersonBloc>().add(UpdateCurrentCheckIn());
                  } else {
                    BotToast.showText(text: LocaleKeys.youWillReceive.tr());
                  }
                  EasyLoading.dismiss();
                  Navigator.of(context).pop();
                } else {
                  BotToast.showText(text: SOMETHING_WENT_WRONG);
                }
              },
              bgColor: blue,
              borderColor: blue,
              textColor: white),
          const SizedBox(height: 16),
          AigraphyWidget.typeButtonStartAction(
              context: context,
              input: LocaleKeys.cancel.tr(),
              vertical: 16,
              onPressed: () {
                Navigator.of(context).pop();
              },
              bgColor: blackCoral,
              borderColor: blackCoral,
              textColor: white),
        ],
      ),
    );
  }
}
