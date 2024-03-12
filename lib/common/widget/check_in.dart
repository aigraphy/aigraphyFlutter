import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../app/widget_support.dart';
import '../../../common/widget/gradient_text.dart';
import '../../features/widget/token_widget.dart';
import '../../translations/export_lang.dart';
import '../bloc/user/bloc_user.dart';
import '../constant/colors.dart';
import '../constant/error_code.dart';
import '../constant/helper.dart';
import '../constant/images.dart';
import '../helper_ads/ads_lovin_utils.dart';
import '../models/user_model.dart';
import 'animation_click.dart';

class CheckInWidget extends StatefulWidget {
  const CheckInWidget({Key? key}) : super(key: key);

  @override
  State<CheckInWidget> createState() => _CheckInWidgetState();
}

class _CheckInWidgetState extends State<CheckInWidget> {
  Future<void> updateTokenUser(int reward) async {
    final UserBloc userBloc = context.read<UserBloc>();
    userBloc.add(UpdateTokenUser(userBloc.userModel!.token + reward));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: grey200,
                        borderRadius: BorderRadius.circular(24)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Image.asset(success, width: 120),
                            const Positioned(
                                right: -60,
                                top: 16,
                                child: TokenWidget(
                                  hasFunction: false,
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
                          child: GradientText(
                            LocaleKeys.checkInAnd.tr(),
                            gradient: Theme.of(context).colorLinear,
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
                          child: GradientText(
                            LocaleKeys.getTokens.tr(),
                            gradient: Theme.of(context).colorLinear,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: AppWidget.typeButtonGradient(
                              context: context,
                              input: LocaleKeys.checkInNow.tr(),
                              vertical: 16,
                              onPressed: () async {
                                final UserModel? user =
                                    context.read<UserBloc>().userModel;
                                if (user != null) {
                                  EasyLoading.show();
                                  final timeNow = await getTime();
                                  if (canCheckIn(user.dateCheckIn, timeNow)) {
                                    context
                                        .read<UserBloc>()
                                        .add(UpdateCurrentCheckIn());
                                  } else {
                                    BotToast.showText(
                                        text: LocaleKeys.youWillReceive.tr());
                                  }
                                  EasyLoading.dismiss();
                                  Navigator.of(context).pop();
                                } else {
                                  BotToast.showText(text: SOMETHING_WENT_WRONG);
                                }
                              },
                              bgColor: primary,
                              borderColor: primary,
                              textColor: grey1100),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: AppWidget.typeButtonStartAction2(
                              context: context,
                              input: '+$TOKEN_REWARD ${LocaleKeys.tokens.tr()}',
                              vertical: 16,
                              icon: video_camera,
                              colorAsset: grey100,
                              onPressed: () {
                                Navigator.of(context).pop();
                                showRewardApplovin(context, updateTokenUser,
                                    reward: TOKEN_REWARD);
                              },
                              bgColor: grey1100,
                              borderColor: grey1100,
                              textColor: grey100),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
                left: 32,
                top: 32,
                child: AnimationClick(
                  function: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: grey300,
                        borderRadius: BorderRadius.circular(48)),
                    child: Image.asset(
                      icClose,
                      width: 20,
                      height: 20,
                      color: grey1100,
                    ),
                  ),
                ))
          ],
        ),
      ],
    );
  }
}
