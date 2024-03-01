import 'dart:async';

import 'package:applovin_max/applovin_max.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app/app.dart';
import 'common/helper_ads/ads_lovin_utils.dart';
import 'translations/codegen_loader.g.dart';

Future<void> main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  tz.initializeTimeZones();
  await MobileAds.instance.initialize();
  await AppLovinMAX.initialize(AdLovinUtils().keySdkApplovin);
  await EasyLocalization.ensureInitialized();
  // if (Platform.isMacOS || Platform.isIOS) {
  //   /* MUST CONFIG */
  //   await Firebase.initializeApp(
  //       options: const FirebaseOptions(
  //           apiKey: 'your_api_key',
  //           appId: 'your_app_id',
  //           messagingSenderId: 'your_messaging_sender_id',
  //           projectId: 'your_project_id'));
  // } else {
  //   await Firebase.initializeApp(
  //       name: 'Face Swap Android',
  //       options: const FirebaseOptions(
  //         appId: 'your_app_id',
  //         apiKey: 'your_api_key',
  //         projectId: 'your_project_id',
  //         authDomain: 'domain_vercel_nodejs',
  //         messagingSenderId: 'your_messaging_sender_id',
  //       ));
  // }

  runApp(EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('hi'),
        Locale('ja'),
        Locale('pt'),
        Locale('vi'),
        Locale('it'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      saveLocale: false,
      useOnlyLangCode: true,
      assetLoader: const CodegenLoader(),
      child: const MyApp()));
}
