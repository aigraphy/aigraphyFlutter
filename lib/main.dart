import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'aigraphy.dart';
import 'translations/codegen_loader.g.dart';

Future<void> main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  tz.initializeTimeZones();
  await EasyLocalization.ensureInitialized();
  if (Platform.isMacOS || Platform.isIOS) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: 'AIzaSyCLUqlbAPYbLusw4m2v3aIiayCcp4JjwpM',
            appId: '1:635220140788:ios:accea587da88cc480a34a1',
            messagingSenderId: '635220140788',
            projectId: 'aigraphy-e594d'));
  } else {
    await Firebase.initializeApp(
        name: 'AIGraphy Android',
        options: const FirebaseOptions(
          appId: '1:635220140788:android:c11e9cfb93777a830a34a1',
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
        Locale('fr'),
        Locale('pt'),
        Locale('it'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      saveLocale: false,
      useOnlyLangCode: true,
      assetLoader: const CodegenLoader(),
      child: const AIGraphy()));
}
