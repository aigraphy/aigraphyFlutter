import 'dart:async';

import 'package:applovin_max/applovin_max.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

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
import '../../translations/export_lang.dart';
import '../widget/item_price.dart';
import '../widget/web_view_privacy.dart';

final List<String> _kProductIds = <String>[
  tokenIdentifier1,
  tokenIdentifier2,
  tokenIdentifier4
];

class PriceScreen extends PageRouteBuilder {
  PriceScreen({this.showDaily = false, this.currentIndex})
      : super(
            pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) =>
                PriceToken(showDaily: showDaily, currentIndex: currentIndex));
  final bool showDaily;
  final int? currentIndex;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return SlideTransition(
      position:
          Tween<Offset>(begin: const Offset(0, 1), end: const Offset(.0, .0))
              .animate(controller!),
      child: PriceToken(showDaily: showDaily, currentIndex: currentIndex),
    );
  }
}

class PriceToken extends StatefulWidget {
  const PriceToken({super.key, this.showDaily = false, this.currentIndex});
  final bool showDaily;
  final int? currentIndex;

  @override
  State<PriceToken> createState() => _PriceState();
}

class _PriceState extends State<PriceToken>
    with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  bool isChecked = true;
  int _currentIndex = 1;
  int _tokens = 1950;
  String identifier = tokenIdentifier2;
  List<StoreProduct> products = [];
  List<Map<String, dynamic>> tokens = [];

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
    if (storeProduct.identifier == _kProductIds[_currentIndex]) {
      try {
        EasyLoading.show();
        await Purchases.purchaseStoreProduct(storeProduct);
        await setRewardTokenIAP(_tokens);
        await Purchases.syncPurchases();
        EasyLoading.dismiss();
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

  @override
  void initState() {
    // getInappPurchase();
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

    if (widget.currentIndex != null) {
      _currentIndex = 2;
      _tokens = 10000;
      identifier = tokenIdentifier4;
    } else {
      _currentIndex = 1;
      _tokens = 1950;
      identifier = tokenIdentifier2;
    }

    tokens = [
      {
        'token': 500,
        'bonus': 0,
        'money': 1.99,
        'selected': false,
        'identifier': tokenIdentifier1
      },
      {
        'token': 1500,
        'bonus': 450,
        'money': 9.99,
        'selected': widget.currentIndex == null,
        'useful': 'Save 30%',
        'identifier': tokenIdentifier2
      },
      {
        'token': 5000,
        'money': 39.99,
        'selected': widget.currentIndex != null,
        'bonus': 5000,
        'useful': 'Save 40%',
        'identifier': tokenIdentifier4
      }
    ];
    AppLovinMAX.loadRewardedAd(AdLovinUtils().rewardAdUnitIdApplovin);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = AppWidget.getWidthScreen(context);
    final height = AppWidget.getHeightScreen(context);
    return WillPopScope(
      onWillPop: () async {
        if (widget.showDaily) {
          Navigator.of(context).pop(true);
        } else {
          Navigator.of(context).pop();
        }
        return false;
      },
      child: Scaffold(
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppWidget.typeButtonGradientAfter(
                  context: context,
                  input:
                      '${LocaleKeys.buyNow.tr()} + ${formatToken(context).format(_tokens)}',
                  bgColor: isChecked ? primary : grey600,
                  textColor: grey1100,
                  icon: token,
                  sizeAsset: 16,
                  borderColor: isChecked ? primary : grey600,
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
              AnimationClick(
                function: () {
                  Navigator.of(context).pushNamed(Routes.term,
                      arguments: const WebViewPrivacy());
                },
                child: Text('Term & Policy',
                    style: subhead(color: grey800, fontWeight: '400')),
              )
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
                          height: height / 4,
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
                      ? () async {
                          if (widget.showDaily) {
                            Navigator.of(context).pop(true);
                          } else {
                            Navigator.of(context).pop();
                          }
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
                      gradient: Theme.of(context).colorLinear,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          video_camera,
                          width: 24,
                          height: 24,
                          color: grey1100,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          '+$TOKEN_REWARD ${LocaleKeys.tokens.tr()}',
                          style: body(color: grey1100, fontWeight: '600'),
                        ),
                      ],
                    ),
                  ),
                )),
            Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GradientText(
                      'Buy Coin',
                      style: const TextStyle(
                          fontSize: 32,
                          height: 1.5,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'ClashGrotesk'),
                      gradient: Theme.of(context).colorLinear,
                    ),
                    Text('Remove Ads & Unlock All Feature',
                        style: body(color: grey1100)),
                    const SizedBox(height: 48),
                    SizedBox(
                      height: 150,
                      child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemBuilder: (context, index) {
                            return AnimationClick(
                              function: () {
                                for (dynamic r in tokens) {
                                  r['selected'] = false;
                                }
                                tokens[index]['selected'] = true;
                                setState(() {
                                  _currentIndex = index;
                                  identifier = tokens[index]['identifier'];
                                  _tokens = tokens[index]['token'] +
                                      tokens[index]['bonus'];
                                });
                              },
                              child: ItemPrice(
                                point: tokens[index],
                                index: index,
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 16),
                          itemCount: tokens.length),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
