import 'dart:async';
import 'dart:io';

import 'package:applovin_max/applovin_max.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app/app.dart';
import 'translations/codegen_loader.g.dart';

Future<void> main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  tz.initializeTimeZones();
  // await MobileAds.instance.initialize();
  // await AppLovinMAX.initialize(AdLovinUtils().keySdkApplovin);
  await EasyLocalization.ensureInitialized();
  if (Platform.isMacOS || Platform.isIOS) {
    /* MUST CONFIG */
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: 'AIzaSyCLUqlbAPYbLusw4m2v3aIiayCcp4JjwpM',
            appId: '1:635220140788:android:2a9c6e326fdbf8b40a34a1',
            messagingSenderId: '635220140788',
            projectId: 'aigraphy-e594d'));
  } else {
    await Firebase.initializeApp(
        name: 'AIGraphy Android',
        options: const FirebaseOptions(
          appId: '1:635220140788:android:2a9c6e326fdbf8b40a34a1',
          apiKey: 'AIzaSyAoI1ZyaErdrDlGCau3x5Th5EafVU1-HZY',
          projectId: 'aigraphy-e594d',
          authDomain: 'aigraphy.vercel.app',
          messagingSenderId: '635220140788',
        ));
  }

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
