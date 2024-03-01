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
import '../../common/helper_ads/ads_lovin_utils.dart';
import '../../common/route/routes.dart';
import '../../common/widget/animation_click.dart';
import '../../common/widget/gradient_text.dart';
import '../../translations/export_lang.dart';
import '../bloc/remove_bg_image/bloc_remove_bg_image.dart';
import '../screen/price.dart';
import 'guide_remove.dart';
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
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    checkHasAds();
    options = [
      {
        'title': LocaleKeys.human.tr(),
        'option': '1',
      },
      {
        'title': LocaleKeys.anime.tr(),
        'option': '2',
      },
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
                fontFamily: 'SpaceGrotesk'),
            gradient: Theme.of(context).linearGradientCustome,
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: GradientText(
            '${LocaleKeys.wi.tr()} $TOKEN_REMOVE_BG ${LocaleKeys.tokens.tr()}',
            style: const TextStyle(
                fontSize: 28,
                height: 1,
                fontWeight: FontWeight.w700,
                fontFamily: 'SpaceGrotesk'),
            gradient: Theme.of(context).linearGradientCustome,
          ),
        ),
        ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return AnimationClick(
                function: () {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: _currentIndex == index ? grey1000 : grey300)),
                  child: Text(
                    options[index]['title'],
                    style: headline(color: grey1100),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemCount: options.length),
        AnimationClick(
          function: () {
            showGeneralDialog(
                barrierColor: grey100.withOpacity(0.5),
                transitionBuilder: (context, a1, a2, widget) {
                  return Transform.scale(
                    scale: a1.value,
                    child: Opacity(
                      opacity: a1.value,
                      child: const GuideRemove(),
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 200),
                barrierDismissible: true,
                barrierLabel: '',
                context: context,
                pageBuilder: (context, animation1, animation2) {
                  return const SizedBox();
                });
          },
          child: Text(
            LocaleKeys.viewGuideOption.tr(),
            textAlign: TextAlign.center,
            style: subhead(color: grey800, hasUnderLine: true),
          ),
        ),
        const SizedBox(height: 16),
        AppWidget.typeButtonStartAction(
            context: context,
            input: LocaleKeys.removeNow.tr(),
            borderRadius: 12,
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
                showInterApplovin(context, () {}, seconds: 5);
                BlocProvider.of<RemoveBGImageBloc>(context).add(
                    InitialRemoveBGImage(
                        context: widget.ctx,
                        link: widget.link,
                        requestId: widget.requestId,
                        option: options[_currentIndex]['option']));
                FirebaseAnalytics.instance.logEvent(name: 'click_remove_bg');
                Navigator.of(context).pop();
              }
            },
            bgColor: primary,
            borderColor: primary,
            textColor: grey1100),
        const SizedBox(height: 8),
        AppWidget.typeButtonStartAction(
            context: context,
            input:
                '${LocaleKeys.watchAdsGet.tr()} $TOKEN_REWARD ${LocaleKeys.tokens.tr()}',
            borderRadius: 12,
            onPressed: () {
              showRewardApplovin(context, updateTokenUser,
                  reward: TOKEN_REWARD);
            },
            bgColor: grey100,
            borderColor: grey100,
            textColor: grey1100),
        const SizedBox(height: 8),
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
        const SizedBox(height: 24)
      ],
    );
  }
}
