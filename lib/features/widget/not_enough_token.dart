import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
import '../screen/price.dart';

class NotEnoughToken extends StatelessWidget {
  const NotEnoughToken({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> updateTokenUser(int reward) async {
      final UserBloc userBloc = context.read<UserBloc>();
      userBloc.add(UpdateTokenUser(userBloc.userModel!.token + reward));
      Navigator.of(context).pop();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                    color: grey200, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Image.asset(
                        token,
                        width: 64,
                        height: 64,
                      ),
                    ),
                    GradientText(
                      LocaleKeys.youDontHave.tr(),
                      style: const TextStyle(
                          fontSize: 28,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'SpaceGrotesk'),
                      gradient: Theme.of(context).linearGradientCustome,
                    ),
                    const SizedBox(height: 4),
                    GradientText(
                      LocaleKeys.enoughToken.tr(),
                      style: const TextStyle(
                          fontSize: 28,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'SpaceGrotesk'),
                      gradient: Theme.of(context).linearGradientCustome,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: Text(
                        LocaleKeys.tryToBuy.tr(),
                        textAlign: TextAlign.center,
                        style: subhead(color: grey1100, fontWeight: '400'),
                      ),
                    ),
                    AppWidget.typeButtonStartAction(
                        context: context,
                        input: LocaleKeys.buyMoreToken.tr(),
                        borderRadius: 12,
                        onPressed: () {
                          Navigator.of(context).pushNamed(Routes.price,
                              arguments: PriceScreen());
                        },
                        bgColor: primary,
                        borderColor: primary,
                        textColor: grey1100),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 24)
                  ],
                ),
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
                        color: grey200,
                        borderRadius: BorderRadius.circular(48)),
                    child: Image.asset(
                      icClose,
                      width: 20,
                      height: 20,
                      color: grey600,
                    ),
                  ),
                ))
          ],
        ),
      ],
    );
  }
}
