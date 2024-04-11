import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:graphql/client.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../translations/export_lang.dart';
import '../bloc/cate_today/cate_today_bloc.dart';
import '../bloc/cate_trending/cate_trending_bloc.dart';
import '../bloc/categories/categories_bloc.dart';
import '../bloc/current_bottombar/current_bottombar_bloc.dart';
import '../bloc/histories/histories_bloc.dart';
import '../bloc/like_post/bloc_like_post.dart';
import '../bloc/list_posts/list_posts_bloc.dart';
import '../config/config_color.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../config/config_local_noti.dart';
import '../config/config_noti_FCM.dart';
import '../config_graphql/config_query.dart';
import '../config_graphql/graphql.dart';
import '../config_model/like_post_model.dart';
import 'explored.dart';
import 'histories.dart';
import 'new_feed.dart';
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
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  Future<void> loadInitData() async {
    Future.delayed(const Duration(seconds: 1)).whenComplete(() {
      listenPersonInfo(mounted, context);
      getLanguagePerson(context);
      getLikedPost(context);
      context.read<CategoriesBloc>().add(CategoriesFetched());
      context.read<CateTodayBloc>().add(CateTodayFetched());
      context.read<CateTrendingBloc>().add(CateTrendingFetched());
      context.read<HistoriesBloc>().add(HistoriesFetched(context: context));
      listenFaces(mounted, context);
    });
    await Purchases.setEmail(userFB.email!);
    listenIAP(context);
    createLocalNoti();
    showPriceScreen(context);
    checkUserPro(context);
  }

  Future<void> getLikedPost(BuildContext context) async {
    final List<LikePostModel> likedPosts = [];
    final User _firebaseUser = FirebaseAuth.instance.currentUser!;
    final String? token = await _firebaseUser.getIdToken();
    await Graphql.initialize(token!)
        .value
        .query(QueryOptions(
            document: gql(ConfigQuery.getLikedPost),
            variables: <String, dynamic>{'user_uuid': _firebaseUser.uid}))
        .then((value) async {
      if (!value.hasException && value.data!['LikePost'].length > 0) {
        for (dynamic res in value.data!['LikePost']) {
          final LikePostModel likedPost = LikePostModel.fromJson(res);
          likedPosts.add(likedPost);
        }
      }
      BlocProvider.of<LikePostBloc>(context)
          .add(GetLikePost(likedPosts: likedPosts));
    });
  }

  BottomNavigationBarItem createItemNav(BuildContext context,
      String iconInactive, String iconActive, String label,
      {double sizeIcon = 24}) {
    return BottomNavigationBarItem(
        activeIcon: Image.asset(
          iconActive,
          width: sizeIcon,
          height: sizeIcon,
          fit: BoxFit.cover,
        ),
        icon: Image.asset(
          iconInactive,
          width: sizeIcon,
          height: sizeIcon,
          fit: BoxFit.cover,
        ),
        label: label);
  }

  @override
  void initState() {
    super.initState();
    context.read<CurrentBottomBar>().setIndex(widget.index);
    context.read<ListPostsBloc>().add(ListPostsFetched());
    listWidget = [
      const SwapCate(),
      const NewFeed(),
      const Explored(),
      const Histories(),
    ];
    loadInitData();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        return;
      }
      EasyLoading.dismiss();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
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
                  createItemNav(context, ic_newfeed, ic_newfeed_active,
                      LocaleKeys.category.tr(),
                      sizeIcon: 20),
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
