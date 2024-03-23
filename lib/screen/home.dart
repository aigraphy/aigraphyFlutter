import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../translations/export_lang.dart';
import '../aigraphy_widget.dart';
import '../bloc/categories/categories_bloc.dart';
import '../bloc/histories/histories_bloc.dart';
import '../bloc/new_today/new_today_bloc.dart';
import '../bloc/set_index_bottombar/set_index_bottombar_bloc.dart';
import '../bloc/trending/trending_bloc.dart';
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
      context.read<NewTodayBloc>().add(NewTodayFetched());
      context.read<TrendingBloc>().add(TrendingFetched());
      context.read<HistoriesBloc>().add(HistoriesFetched(context: context));
      listenFaces(mounted, context);
    });
    await Purchases.setEmail(userFB.email!);
    listenInAppPurchase(context);
    createLocalNoti();
    showPrice(context);
    checkUserPro(context);
  }

  @override
  void initState() {
    super.initState();
    context.read<SetIndexBottomBar>().setIndex(widget.index);
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
        index: context.watch<SetIndexBottomBar>().state,
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
                currentIndex: context.watch<SetIndexBottomBar>().state,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                backgroundColor: spaceCadet,
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                onTap: (value) {
                  context.read<SetIndexBottomBar>().setIndex(value);
                },
                items: [
                  AigraphyWidget.createItemNav(context, swap_cate,
                      swap_cate_active, LocaleKeys.category.tr()),
                  AigraphyWidget.createItemNav(context, take_photo,
                      take_photo_active, LocaleKeys.home.tr()),
                  AigraphyWidget.createItemNav(
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
