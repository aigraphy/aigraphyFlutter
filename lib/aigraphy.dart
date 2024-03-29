import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'bloc/all_img_cate/all_img_cate_bloc.dart';
import 'bloc/cate_today/cate_today_bloc.dart';
import 'bloc/cate_trending/cate_trending_bloc.dart';
import 'bloc/categories/categories_bloc.dart';
import 'bloc/current_bottombar/current_bottombar_bloc.dart';
import 'bloc/current_cate/current_cate_bloc.dart';
import 'bloc/current_img_swap/current_img_swap_bloc.dart';
import 'bloc/face/bloc_face.dart';
import 'bloc/histories/histories_bloc.dart';
import 'bloc/like_post/bloc_like_post.dart';
import 'bloc/list_posts/list_posts_bloc.dart';
import 'bloc/listen_language/bloc_listen_language.dart';
import 'bloc/pageview/pageview_bloc.dart';
import 'bloc/person/bloc_person.dart';
import 'bloc/photo/photo_bloc.dart';
import 'bloc/rem_bg_img/bloc_rem_bg_img.dart';
import 'bloc/set_user_pro/set_user_pro_bloc.dart';
import 'bloc/show_offer/show_offer.dart';
import 'bloc/swap_img/bloc_swap_img.dart';
import 'config/config_color.dart';
import 'config/config_font_styles.dart';
import 'config/config_helper.dart';
import 'config/config_image.dart';
import 'config/config_noti_FCM.dart';
import 'config_router/generate_router.dart';
import 'screen/introduce.dart';
import 'screen/introduce_second.dart';
import 'util/config_shared_pre.dart';
import 'widget/lottie_custom.dart';

final navigateKey = GlobalKey<NavigatorState>();

class AIGraphy extends StatefulWidget {
  const AIGraphy({Key? key}) : super(key: key);
  @override
  State<AIGraphy> createState() => _AIGraphyState();
}

class _AIGraphyState extends State<AIGraphy> {
  Future<String?> getToken() async {
    final User? userFB = FirebaseAuth.instance.currentUser;
    if (userFB == null) {
      return null;
    }
    final String? token = await userFB.getIdToken();
    return token;
  }

  Future<void> showPrice() async {
    if (isIOS) {
      await setBoolVal(true, 'show_price');
    }
  }

  Future<void> showPushNoti() async {
    await FirebaseApi().initNotify();
  }

  @override
  void initState() {
    super.initState();
    getToken();
    configRevenueCat(context);
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.custom
      ..userInteractions = false
      ..backgroundColor = Colors.transparent
      ..indicatorColor = Colors.transparent
      ..maskColor = gray1000
      ..textColor = Colors.transparent
      ..boxShadow = <BoxShadow>[]
      ..progressColor = yellow1
      ..textStyle = style9(color: white)
      ..textColor = white
      ..indicatorWidget = const LottieCustom(
        lottie: waiting,
        height: 100,
      );
    showPrice();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    final botToastBuilder = BotToastInit();
    return MultiBlocProvider(
      providers: [
        BlocProvider<PageViewCubit>(
          create: (BuildContext context) => PageViewCubit(),
        ),
        BlocProvider<PersonBloc>(
          create: (BuildContext context) => PersonBloc(),
        ),
        BlocProvider<SwapImgBloc>(
          create: (BuildContext context) => SwapImgBloc(),
        ),
        BlocProvider<FaceBloc>(
          create: (BuildContext context) => FaceBloc(),
        ),
        BlocProvider<CategoriesBloc>(
          create: (BuildContext context) => CategoriesBloc(),
        ),
        BlocProvider<CurrentImgSwapCubit>(
          create: (BuildContext context) => CurrentImgSwapCubit(),
        ),
        BlocProvider<ListenLanguageBloc>(
          create: (BuildContext context) => ListenLanguageBloc(),
        ),
        BlocProvider<PhotosBloc>(
          create: (BuildContext context) => PhotosBloc(),
        ),
        BlocProvider<HistoriesBloc>(
          create: (BuildContext context) => HistoriesBloc(),
        ),
        BlocProvider<AllImgCateBloc>(
          create: (BuildContext context) => AllImgCateBloc(),
        ),
        BlocProvider<CateTodayBloc>(
          create: (BuildContext context) => CateTodayBloc(),
        ),
        BlocProvider<CateTrendingBloc>(
          create: (BuildContext context) => CateTrendingBloc(),
        ),
        BlocProvider<CurrentBottomBar>(
          create: (BuildContext context) => CurrentBottomBar(),
        ),
        BlocProvider<RemBGImgBloc>(
          create: (BuildContext context) => RemBGImgBloc(),
        ),
        BlocProvider<ShowOffer>(
          create: (BuildContext context) => ShowOffer(),
        ),
        BlocProvider<CurrentCate>(
          create: (BuildContext context) => CurrentCate(),
        ),
        BlocProvider<SetUserPro>(
          create: (BuildContext context) => SetUserPro(),
        ),
        BlocProvider<LikePostBloc>(
          create: (BuildContext context) => LikePostBloc(),
        ),
        BlocProvider<ListPostsBloc>(
          create: (BuildContext context) => ListPostsBloc(),
        ),
      ],
      child: MaterialApp(
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
        ],
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        initialRoute: '/',
        onGenerateRoute: GeneratorRouter.generateRouter,
        title: 'AIGraphy',
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        darkTheme: darkMode,
        navigatorKey: navigateKey,
        themeMode: ThemeMode.dark,
        builder: (context, child) {
          child = EasyLoading.init(
            builder: (context, child) {
              return ResponsiveWrapper.builder(child,
                  maxWidth: 1200,
                  minWidth: 480,
                  defaultScale: true,
                  breakpoints: const [
                    ResponsiveBreakpoint.resize(480, name: MOBILE),
                    ResponsiveBreakpoint.autoScale(800, name: TABLET),
                    ResponsiveBreakpoint.resize(1000, name: DESKTOP),
                    ResponsiveBreakpoint.autoScale(2460, name: '4K'),
                  ],
                  background: Container(color: const Color(0xFFF5F5F5)));
            },
          )(context, child);
          child = botToastBuilder(context, child);
          return child;
        },
        home: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: FutureBuilder<String?>(
            future: getToken(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                case ConnectionState.active:
                  return const Center(
                    child: CupertinoActivityIndicator(
                      animating: true,
                    ),
                  );
                case ConnectionState.done:
                  showPushNoti();
                  FlutterNativeSplash.remove();
                  if (snapshot.data != null) {
                    return const IntroduceSecond();
                  } else {
                    return const Introduce();
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}
