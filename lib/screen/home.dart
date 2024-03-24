import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../translations/export_lang.dart';
import '../bloc/cate_today/cate_today_bloc.dart';
import '../bloc/cate_trending/cate_trending_bloc.dart';
import '../bloc/categories/categories_bloc.dart';
import '../bloc/current_bottombar/current_bottombar_bloc.dart';
import '../bloc/histories/histories_bloc.dart';
import '../config/config_color.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../config/config_local_noti.dart';
import '../config/config_noti_FCM.dart';
import 'explored.dart';
import 'histories.dart';
import 'swap_cate.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.index = 0});
  final int index;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User userFB = FirebaseAuth.instance.currentUser!;
  List<Widget> listWidget = [];

  Future<void> loadInitData() async {
    Future.delayed(const Duration(seconds: 1)).whenComplete(() {
      listenPersonInfo(mounted, context);
      getLanguagePerson(context);
      context.read<CategoriesBloc>().add(CategoriesFetched());
      context.read<CateTodayBloc>().add(CateTodayFetched());
      context.read<CateTrendingBloc>().add(CateTrendingFetched());
      context.read<HistoriesBloc>().add(HistoriesFetched(context: context));
      listenFaces(mounted, context);
    });
    await Purchases.setEmail(userFB.email!);
    listenInAppPurchase(context);
    createLocalNoti();
    showPrice(context);
    checkUserPro(context);
  }

  BottomNavigationBarItem createItemNav(BuildContext context,
      String iconInactive, String iconActive, String label) {
    return BottomNavigationBarItem(
        activeIcon: Image.asset(
          iconActive,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
        ),
        icon: Image.asset(
          iconInactive,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
        ),
        label: label);
  }

  @override
  void initState() {
    super.initState();
    context.read<CurrentBottomBar>().setIndex(widget.index);
    listWidget = [
      const SwapCate(),
      const Explored(),
      const Histories(),
    ];
    loadInitData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: context.watch<CurrentBottomBar>().state,
        children: listWidget,
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButton: Row(
        children: [
          const Expanded(child: SizedBox()),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BottomNavigationBar(
                currentIndex: context.watch<CurrentBottomBar>().state,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                backgroundColor: spaceCadet,
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                onTap: (value) {
                  context.read<CurrentBottomBar>().setIndex(value);
                },
                items: [
                  createItemNav(context, swap_cate, swap_cate_active,
                      LocaleKeys.category.tr()),
                  createItemNav(context, take_photo, take_photo_active,
                      LocaleKeys.home.tr()),
                  createItemNav(
                      context, person, person_active, LocaleKeys.profile.tr()),
                ],
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}
