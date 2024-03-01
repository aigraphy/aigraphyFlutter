import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

ThemeData lightMode = ThemeData(
  scaffoldBackgroundColor: grey1100,
  bottomNavigationBarTheme:
      const BottomNavigationBarThemeData(backgroundColor: grey1100),
  appBarTheme: const AppBarTheme(
    color: grey1100,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
      .copyWith(background: grey1100, brightness: Brightness.light),
);
ThemeData darkMode = ThemeData(
  scaffoldBackgroundColor: grey100,
  bottomNavigationBarTheme:
      const BottomNavigationBarThemeData(backgroundColor: grey100),
  appBarTheme: const AppBarTheme(
    color: grey100,
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
      .copyWith(background: grey100, brightness: Brightness.dark),
);
