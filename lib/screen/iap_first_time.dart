import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../translations/export_lang.dart';
import '../aigraphy_widget.dart';
import '../bloc/person/bloc_person.dart';
import '../bloc/show_offer/show_offer.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../config_router/name_router.dart';
import '../util/config_shared_pre.dart';
import '../widget/click_widget.dart';
import '../widget/item_iap.dart';
import '../widget/privacy.dart';
import '../widget/text_gradient.dart';

final List<String> _kProductIds = <String>[
  coinProductId1,
  coinProductId2,
  coinProductId3
];

class IAPFirstTime extends PageRouteBuilder {
  IAPFirstTime({this.currentIndex})
      : super(
            pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) =>
                IAPFirstTimeCoin(currentIndex: currentIndex));
  final int? currentIndex;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return SlideTransition(
      position:
          Tween<Offset>(begin: const Offset(0, 1), end: const Offset(.0, .0))
              .animate(controller!),
      child: IAPFirstTimeCoin(currentIndex: currentIndex),
    );
  }
}

class IAPFirstTimeCoin extends StatefulWidget {
  const IAPFirstTimeCoin({super.key, this.currentIndex});
  final int? currentIndex;

  @override
  State<IAPFirstTimeCoin> createState() => _IAPFirstTimeState();
}

class _IAPFirstTimeState extends State<IAPFirstTimeCoin>
    with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  bool isChecked = true;
  int _currentIndex = 1;
  int _coins = 1950;
  String identifier = coinProductId2;
  List<StoreProduct> products = [];
  List<Map<String, dynamic>> coins = [];

  Future<void> updateCoinUser(int reward) async {
    final PersonBloc userBloc = context.read<PersonBloc>();
    userBloc.add(UpdateCoinUser(userBloc.userModel!.coin + reward));
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
        await setCoinIAP(_coins * 2);
        await Purchases.syncPurchases();
        EasyLoading.dismiss();
        context.read<ShowOffer>().reset();
        Navigator.of(context).pop();
      } on PlatformException catch (e) {
        final errorCode = PurchasesErrorHelper.getErrorCode(e);
        if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
          BotToast.showText(text: LocaleKeys.thePurchaseHasBeenCancelled.tr());
        } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
          BotToast.showText(text: LocaleKeys.thePurchaseIsStill.tr());
          await setCoinIAP(_coins);
        }
        EasyLoading.dismiss();
      }
    } else {
      BotToast.showText(text: SOMETHING_WENT_WRONG);
    }
  }

  @override
  void initState() {
    super.initState();
    getInappPurchase();
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
      _coins = 10000;
      identifier = coinProductId3;
    } else {
      _currentIndex = 1;
      _coins = 1950;
      identifier = coinProductId2;
    }

    coins = [
      {
        'coin': 500,
        'bonus': 0,
        'money': 1.99,
        'selected': false,
        'identifier': coinProductId1
      },
      {
        'coin': 1500,
        'bonus': 450,
        'money': 9.99,
        'selected': widget.currentIndex == null,
        'useful': 'Save 30%',
        'identifier': coinProductId2
      },
      {
        'coin': 5000,
        'money': 39.99,
        'selected': widget.currentIndex != null,
        'bonus': 5000,
        'useful': 'Save 40%',
        'identifier': coinProductId3
      }
    ];
    // AppLovinMAX.loadRewardedAd(AdLovinUtils().rewardAdUnitIdApplovin);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = AigraphyWidget.getWidth(context);
    final height = AigraphyWidget.getHeight(context);
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AigraphyWidget.typeButtonGradientAfter(
                context: context,
                input:
                    '${LocaleKeys.buyNow.tr()} + ${formatCoin(context).format(_coins * 2)}',
                bgColor: isChecked ? blue : isabelline,
                textColor: white,
                borderColor: isChecked ? blue : isabelline,
                icon: coin,
                sizeAsset: 16,
                onPressed: isChecked
                    ? () async {
                        if (products.isNotEmpty) {
                          await makeAPurchase(products
                              .firstWhere((e) => e.identifier == identifier));
                        } else {
                          BotToast.showText(
                              text: SOMETHING_WENT_WRONG,
                              textStyle: style7(color: white));
                        }
                      }
                    : () {}),
            const SizedBox(height: 8),
            ClickWidget(
              function: () {
                Navigator.of(context)
                    .pushNamed(Routes.policy, arguments: const Privacy());
              },
              child: Text('Term & Policy',
                  style: style9(color: cultured, fontWeight: '400')),
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
                        height: height / 1.5,
                        width: width,
                        decoration: BoxDecoration(
                            gradient: Theme.of(context).linerPrice),
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
              child: ClickWidget(
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
                          color: white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(48)),
                      child: Image.asset(
                        icClose,
                        width: 20,
                        height: 20,
                        color: white,
                      ),
                    ),
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        gradient: Theme.of(context).linerPimary,
                        borderRadius: BorderRadius.circular(48)),
                    child: Image.asset(gift, width: 48, height: 48),
                  ),
                  const SizedBox(height: 16),
                  TextGradient(
                    'First Time Payment',
                    style: const TextStyle(
                        fontSize: 36,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'ClashGrotesk'),
                    gradient: Theme.of(context).linerPimary,
                  ),
                  Text('X2 Coins', style: style2(color: yellow1)),
                  const SizedBox(height: 48),
                  SizedBox(
                    height: 150,
                    child: ListView.separated(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemBuilder: (context, index) {
                          return ClickWidget(
                            function: () {
                              for (dynamic r in coins) {
                                r['selected'] = false;
                              }
                              coins[index]['selected'] = true;
                              setState(() {
                                _currentIndex = index;
                                identifier = coins[index]['identifier'];
                                _coins = coins[index]['coin'] +
                                    coins[index]['bonus'];
                              });
                            },
                            child: ItemIAP(
                              point: coins[index],
                              index: index,
                            ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 16),
                        itemCount: coins.length),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
