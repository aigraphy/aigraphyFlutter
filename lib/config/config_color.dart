import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData darkMode = ThemeData(
  scaffoldBackgroundColor: black,
  bottomNavigationBarTheme:
      const BottomNavigationBarThemeData(backgroundColor: black),
  appBarTheme: const AppBarTheme(
    color: black,
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
      .copyWith(background: black, brightness: Brightness.dark),
);

ThemeData lightMode = ThemeData(
  scaffoldBackgroundColor: white,
  bottomNavigationBarTheme:
      const BottomNavigationBarThemeData(backgroundColor: white),
  appBarTheme: const AppBarTheme(
    color: white,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
      .copyWith(background: white, brightness: Brightness.light),
);

const Color white = Color(0xFFFFFFFF);
const Color gray1000 = Color(0xFFF2F8F8);
const Color gray900 = Color(0xFFD7EAEA);
const Color cultured = Color(0xFFBCDCDC);
const Color whiteSmoke = Color(0xFFA1CECE);
const Color isabelline = Color(0xFF79B9B9);
const Color platinum = Color(0xFF54A0A0);
const Color cadetBlueCrayola = Color(0xFF386B6B);
const Color blackCoral = Color(0xFF234343);
const Color spaceCadet = Color(0xFF152929);
const Color black = Color(0xFF010202);
const Color blue = Color(0xFF106AF3);
const Color yellow1 = Color(0xFFF6D938);
const Color yellow2 = Color(0xFFF6D938);
const Color red1 = Color(0xFFE30147);
const Color red2 = Color(0xFFFF647C);
const Color gray = Color(0xFF889098);
const Color green = Color(0xFF00CD50);
const Color gray2 = Color(0xFFB1CEDE);

extension CustomColorTheme on ThemeData {
  LinearGradient get linerIntroduce => LinearGradient(
        end: Alignment.topCenter,
        begin: Alignment.bottomCenter,
        colors: [
          black.withOpacity(1),
          black.withOpacity(0),
        ],
      );
  LinearGradient get linerPrice => LinearGradient(
        end: Alignment.topCenter,
        begin: Alignment.bottomCenter,
        colors: [
          black.withOpacity(1),
          const Color(0xFF000000).withOpacity(0),
        ],
      );
  LinearGradient get linerPimary => LinearGradient(
        end: Alignment.centerRight,
        begin: Alignment.centerLeft,
        colors: [
          const Color(0xFFDFCEEC).withOpacity(0.9),
          const Color(0xFF8639F5).withOpacity(0.9),
          const Color(0xFF73F7E5).withOpacity(0.9),
        ],
      );
}
