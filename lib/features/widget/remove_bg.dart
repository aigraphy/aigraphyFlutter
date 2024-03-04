import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../app/widget_support.dart';
import '../../common/bloc/user/bloc_user.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/route/routes.dart';
import '../../common/widget/gradient_text.dart';
import '../../translations/export_lang.dart';
import '../bloc/remove_bg_image/bloc_remove_bg_image.dart';
import '../screen/price.dart';
import 'not_enough_token.dart';

class RemoveBg extends StatefulWidget {
  const RemoveBg(
      {super.key,
      required this.link,
      required this.requestId,
      required this.ctx});
  final String link;
  final int requestId;
  final BuildContext ctx;
  @override
  State<RemoveBg> createState() => _RemoveBgState();
}

class _RemoveBgState extends State<RemoveBg> {
  List<Map<String, dynamic>> options = [];

  @override
  void initState() {
    super.initState();
    // checkHasAds();
    options = [
      {
        'title': LocaleKeys.humanAndAnimal.tr(),
        'option': null,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    Future<void> updateTokenUser(int reward) async {
      final UserBloc userBloc = context.read<UserBloc>();
      userBloc.add(UpdateTokenUser(userBloc.userModel!.token + reward));
      Navigator.of(context).pop();
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
          child: GradientText(
            LocaleKeys.removeBackground.tr(),
            style: const TextStyle(
                fontSize: 32,
                height: 1,
                fontWeight: FontWeight.w700,
                fontFamily: 'ClashGrotesk'),
            gradient: Theme.of(context).colorLinear,
          ),
        ),
        const SizedBox(height: 24),
        AppWidget.typeButtonGradientAfter(
            context: context,
            input: '${LocaleKeys.removeNow.tr()} -$TOKEN_REMOVE_BG',
            onPressed: () {
              final userModel = context.read<UserBloc>().userModel!;
              if (userModel.token < TOKEN_REMOVE_BG) {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return const NotEnoughToken();
                  },
                );
              } else {
                EasyLoading.show();
                // showInterApplovin(context, () {}, seconds: 5);
                BlocProvider.of<RemoveBGImageBloc>(context).add(
                    InitialRemoveBGImage(
                        context: widget.ctx,
                        link: widget.link,
                        requestId: widget.requestId,
                        option: options[0]['option']));
                FirebaseAnalytics.instance.logEvent(name: 'click_remove_bg');
                Navigator.of(context).pop();
              }
            },
            icon: token,
            sizeAsset: 20,
            textColor: grey1100),
        const SizedBox(height: 8),
        AppWidget.typeButtonStartAction(
            context: context,
            bgColor: grey300,
            borderColor: grey300,
            input:
                '${LocaleKeys.watchAdsGet.tr()} $TOKEN_REWARD ${LocaleKeys.tokens.tr()}',
            onPressed: () {
              // showRewardApplovin(context, updateTokenUser,
              //     reward: TOKEN_REWARD);
            },
            textColor: grey1100),
        const SizedBox(height: 24)
      ],
    );
  }
}
