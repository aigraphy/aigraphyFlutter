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

import '../common/bloc/list_requests/list_requests_bloc.dart';
import '../common/bloc/listen_language/bloc_listen_language.dart';
import '../common/bloc/recent_face/bloc_recent_face.dart';
import '../common/bloc/set_user_pro/set_user_pro_bloc.dart';
import '../common/bloc/slider/slider_bloc.dart';
import '../common/bloc/user/bloc_user.dart';
import '../common/constant/colors.dart';
import '../common/constant/dark_mode.dart';
import '../common/constant/firebase_api.dart';
import '../common/constant/helper.dart';
import '../common/constant/images.dart';
import '../common/constant/styles.dart';
import '../common/preference/shared_preference_builder.dart';
import '../common/route/route_generator.dart';
import '../common/widget/lottie_widget.dart';
import '../features/bloc/full_image_cate/full_image_cate_bloc.dart';
import '../features/bloc/generate_image/bloc_generate_image.dart';
import '../features/bloc/list_categories/list_categories_bloc.dart';
import '../features/bloc/list_photo/list_photo_bloc.dart';
import '../features/bloc/new_today/new_today_bloc.dart';
import '../features/bloc/remove_bg_image/bloc_remove_bg_image.dart';
import '../features/bloc/set_image_swap/set_image_swap_bloc.dart';
import '../features/bloc/set_index_bottombar/set_index_bottombar_bloc.dart';
import '../features/bloc/set_index_category/set_index_category_bloc.dart';
import '../features/bloc/show_gift/show_gift.dart';
import '../features/bloc/trending/trending_bloc.dart';
import '../features/screen/onboarding.dart';
import '../features/screen/onboarding_second.dart';

final navigateKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<String?> getToken() async {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    final String? token = await firebaseUser.getIdToken();
    return token;
  }

  Future<void> showPrice() async {
    if (isIOS) {
      await setSharedBool(true, 'show_price');
    }
  }

  Future<void> showPushNoti() async {
    await FirebaseApi().initNotify();
  }

  @override
  void initState() {
    super.initState();
    getToken();
    initPlatformState(context);
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.custom
      ..userInteractions = false
      ..backgroundColor = Colors.transparent
      ..indicatorColor = Colors.transparent
      ..maskColor = grey1000
      ..textColor = Colors.transparent
      ..boxShadow = <BoxShadow>[]
      ..progressColor = corn1
      ..textStyle = subhead(color: grey1100)
      ..textColor = grey1100
      ..indicatorWidget = const LottieWidget(
        lottie: loading,
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
        BlocProvider<SliderCubit>(
          create: (BuildContext context) => SliderCubit(),
        ),
        BlocProvider<UserBloc>(
          create: (BuildContext context) => UserBloc(),
        ),
        BlocProvider<GenerateImageBloc>(
          create: (BuildContext context) => GenerateImageBloc(),
        ),
        BlocProvider<RecentFaceBloc>(
          create: (BuildContext context) => RecentFaceBloc(),
        ),
        BlocProvider<ListCategoriesBloc>(
          create: (BuildContext context) => ListCategoriesBloc(),
        ),
        BlocProvider<SetImageSwapCubit>(
          create: (BuildContext context) => SetImageSwapCubit(),
        ),
        BlocProvider<ListenLanguageBloc>(
          create: (BuildContext context) => ListenLanguageBloc(),
        ),
        BlocProvider<ListPhotosBloc>(
          create: (BuildContext context) => ListPhotosBloc(),
        ),
        BlocProvider<ListRequestsBloc>(
          create: (BuildContext context) => ListRequestsBloc(),
        ),
        BlocProvider<FullImageCategoryBloc>(
          create: (BuildContext context) => FullImageCategoryBloc(),
        ),
        BlocProvider<NewTodayBloc>(
          create: (BuildContext context) => NewTodayBloc(),
        ),
        BlocProvider<TrendingBloc>(
          create: (BuildContext context) => TrendingBloc(),
        ),
        BlocProvider<SetIndexBottomBar>(
          create: (BuildContext context) => SetIndexBottomBar(),
        ),
        BlocProvider<RemoveBGImageBloc>(
          create: (BuildContext context) => RemoveBGImageBloc(),
        ),
        BlocProvider<ShowGift>(
          create: (BuildContext context) => ShowGift(),
        ),
        BlocProvider<SetIndexCategory>(
          create: (BuildContext context) => SetIndexCategory(),
        ),
        BlocProvider<SetUserPro>(
          create: (BuildContext context) => SetUserPro(),
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
        onGenerateRoute: RouteGenerator.generateRoute,
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
                  // showPushNoti();
                  FlutterNativeSplash.remove();
                  if (snapshot.data != null) {
                    return const OnboardingSecond();
                  } else {
                    return const Onboarding();
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}
