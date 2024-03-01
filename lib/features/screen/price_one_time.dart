import 'dart:async';

import 'package:applovin_max/applovin_max.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:slide_countdown/slide_countdown.dart';

import '../../app/widget_support.dart';
import '../../common/bloc/user/user_bloc.dart';
import '../../common/bloc/user/user_event.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/error_code.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/helper_ads/ads_lovin_utils.dart';
import '../../common/preference/shared_preference_builder.dart';
import '../../common/route/routes.dart';
import '../../common/widget/animation_click.dart';
import '../../common/widget/gradient_text.dart';
import '../../common/widget/lottie_widget.dart';
import '../../translations/export_lang.dart';
import '../bloc/show_gift/show_gift.dart';
import '../widget/web_view_privacy.dart';

final List<String> _kProductIds = <String>[tokenIdentifier4];

class PriceOneTime extends PageRouteBuilder {
  PriceOneTime({this.currentIndex})
      : super(
            pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) =>
                PriceOneTimeToken(currentIndex: currentIndex));
  final int? currentIndex;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return SlideTransition(
      position:
          Tween<Offset>(begin: const Offset(0, 1), end: const Offset(.0, .0))
              .animate(controller!),
      child: PriceOneTimeToken(currentIndex: currentIndex),
    );
  }
}

class PriceOneTimeToken extends StatefulWidget {
  const PriceOneTimeToken({super.key, this.currentIndex});
  final int? currentIndex;

  @override
  State<PriceOneTimeToken> createState() => _PriceOneTimeState();
}

class _PriceOneTimeState extends State<PriceOneTimeToken>
    with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  bool isChecked = true;
  final int _tokens = 10000;
  String identifier = tokenIdentifier4;
  List<StoreProduct> products = [];
  StreamDuration? streamDuration;

  Future<void> updateTokenUser(int reward) async {
    final UserBloc userBloc = context.read<UserBloc>();
    userBloc.add(UpdateTokenUser(userBloc.userModel!.token + reward));
  }

  Future<void> getInappPurchase() async {
    try {
      products = await Purchases.getProducts(
        _kProductIds,
        productCategory: ProductCategory.nonSubscription,
      );
    } on PlatformException catch (_) {
      BotToast.showText(text: SOMETHING_WENT_WRONG);
    }
  }

  Future<void> makeAPurchase(StoreProduct storeProduct) async {
    if (storeProduct.identifier == identifier) {
      try {
        EasyLoading.show();
        await Purchases.purchaseStoreProduct(storeProduct);
        await setRewardTokenIAP(_tokens * 2);
        await Purchases.syncPurchases();
        EasyLoading.dismiss();
        context.read<ShowGift>().reset();
        Navigator.of(context).pop();
      } on PlatformException catch (e) {
        final errorCode = PurchasesErrorHelper.getErrorCode(e);
        if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
          BotToast.showText(text: LocaleKeys.thePurchaseHasBeenCancelled.tr());
        } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
          BotToast.showText(text: LocaleKeys.thePurchaseIsStill.tr());
          await setRewardTokenIAP(_tokens);
        }
        EasyLoading.dismiss();
      }
    } else {
      BotToast.showText(text: SOMETHING_WENT_WRONG);
    }
  }

  Future<void> checkTime() async {
    await Future.delayed(const Duration(seconds: 1));
    final customerInfo = await Purchases.getCustomerInfo();
    if (customerInfo.nonSubscriptionTransactions.isNotEmpty &&
        customerInfo.nonSubscriptionTransactions.length == 1) {
      final latestTran = DateTime.parse(
              customerInfo.nonSubscriptionTransactions[0].purchaseDate)
          .toLocal();
      final timeNow = await getTime();
      final endOfDay = latestTran.add(const Duration(days: 5));
      final isBefore = timeNow.isBefore(endOfDay);
      final isAfter = timeNow.isAfter(latestTran.add(const Duration(days: 4)));
      if (isAfter && isBefore) {
        final diffTemp = endOfDay.difference(timeNow);
        final hours = diffTemp.inHours;
        final minutes = diffTemp.inMinutes.remainder(60);
        final seconds = diffTemp.inSeconds.remainder(60);
        streamDuration = StreamDuration(
            config: StreamDurationConfig(
                onDone: () {
                  context.read<ShowGift>().reset();
                  Navigator.of(context).pop();
                },
                countDownConfig: CountDownConfig(
                    duration: Duration(
                        hours: hours, minutes: minutes, seconds: seconds))));
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getInappPurchase();
    checkTime();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isVisible = true;
        _animationController.forward();
      });
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    AppLovinMAX.loadRewardedAd(AdLovinUtils().rewardAdUnitIdApplovin);
  }

  @override
  void dispose() {
    streamDuration?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = AppWidget.getWidthScreen(context);
    final height = AppWidget.getHeightScreen(context);
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  activeColor: primary,
                  value: isChecked,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4))),
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = !isChecked;
                    });
                  },
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: '${LocaleKeys.youAgreeWithOur.tr()} ',
                    style: body(color: grey1100),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Term & Policy',
                        style: headline(color: grey1100),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).pushNamed(Routes.term,
                                arguments: const WebViewPrivacy());
                          },
                      )
                    ],
                  ),
                ),
              ],
            ),
            AppWidget.typeButtonStartAction2(
                context: context,
                input:
                    '${LocaleKeys.buyNow.tr()} + ${formatToken(context).format(_tokens * 2)} ${LocaleKeys.tokens.tr()}',
                bgColor: isChecked ? primary : grey600,
                textColor: grey1100,
                borderColor: isChecked ? primary : grey600,
                borderRadius: 12,
                onPressed: isChecked
                    ? () async {
                        if (products.isNotEmpty) {
                          await makeAPurchase(products
                              .firstWhere((e) => e.identifier == identifier));
                        } else {
                          BotToast.showText(
                              text: SOMETHING_WENT_WRONG,
                              textStyle: body(color: grey1100));
                        }
                      }
                    : () {}),
            const SizedBox(height: 8),
            Text(version, style: subhead(color: grey800, fontWeight: '400'))
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Stack(
                children: [
                  Image.asset(
                    bg_price,
                    width: width,
                    height: height / 1.3,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  Positioned(
                    bottom: 0,
                    child: IgnorePointer(
                      child: Container(
                        height: height / 1.5,
                        width: width,
                        decoration: BoxDecoration(
                            gradient: Theme.of(context).colorLinearBottom3),
                      ),
                    ),
                  ),
                ],
              ),
              const Expanded(child: SizedBox())
            ],
          ),
          Positioned(
              left: 24,
              top: 64,
              child: AnimationClick(
                function: _isVisible
                    ? () {
                        Navigator.of(context).pop();
                      }
                    : () {},
                child: AnimatedOpacity(
                  opacity: _isVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: grey1100.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(48)),
                      child: Image.asset(
                        icClose,
                        width: 20,
                        height: 20,
                        color: grey1100,
                      ),
                    ),
                  ),
                ),
              )),
          Positioned(
              right: 24,
              top: 64,
              child: AnimationClick(
                function: () {
                  showRewardApplovin(context, updateTokenUser,
                      reward: TOKEN_REWARD);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: Theme.of(context).linearGradientCustome,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        video_ads,
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        '+$TOKEN_REWARD ${LocaleKeys.tokens.tr()}',
                        style: body(color: grey100, fontWeight: '600'),
                      ),
                    ],
                  ),
                ),
              )),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              top: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(),
                  Column(
                    children: [
                      IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              gradient: Theme.of(context).linearGradientCustome,
                              borderRadius: BorderRadius.circular(48)),
                          child: const LottieWidget(lottie: gift, height: 64),
                        ),
                      ),
                      const SizedBox(height: 16),
                      IgnorePointer(
                        child: GradientText(
                          'Just For You',
                          style: const TextStyle(
                              fontSize: 36,
                              height: 1,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'SpaceGrotesk'),
                          gradient: Theme.of(context).linearGradientCustome,
                        ),
                      ),
                      const SizedBox(height: 24),
                      streamDuration != null
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: SlideCountdownSeparated(
                                streamDuration: streamDuration,
                                separatorStyle: title2(color: grey1100),
                                separatorPadding: const EdgeInsets.only(
                                    bottom: 4, left: 2, right: 2),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                  color: green,
                                ),
                                style: title2(color: grey1100),
                              ),
                            )
                          : const SizedBox(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 32),
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: grey200),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('20,000 Tokens', style: title1(color: corn1)),
                            const SizedBox(height: 8),
                            Text('Just \$9.99', style: title3(color: grey1100)),
                            Container(
                              height: 1,
                              width: 80,
                              margin: const EdgeInsets.symmetric(vertical: 24),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: grey300),
                            ),
                            Text('5,000 Token (Basic)',
                                style: body(color: grey1100)),
                            const SizedBox(height: 8),
                            RichText(
                              textAlign: TextAlign.start,
                              text: TextSpan(
                                text: '+5,000 (bonus)',
                                style:
                                    subhead(color: grey600, fontWeight: '400'),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: ' +10,000 (for you)',
                                    style: subhead(
                                        color: corn1, fontWeight: '400'),
                                  ),
                                  TextSpan(
                                    text: ' ${LocaleKeys.tokens.tr()}',
                                    style: subhead(
                                        color: grey600, fontWeight: '400'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ))
        ],
      ),
    );
  }
}
