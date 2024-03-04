import 'package:flutter/material.dart';

//primary
const Color primary = Color(0xFF106AF3);
const Color blueLight = Color(0xFF7AA7EC);
const Color blueLight2 = Color(0xFF429DF0);
const Color blueLight3 = Color(0xFF5784E8);

//Emerald
const Color emerald1 = Color(0xFFC0A975);

//Corn
const Color corn1 = Color(0xFFF6D938);
const Color corn2 = Color(0xFFF6D938);

//Radical Red
const Color radicalRed1 = Color(0xFFE30147);
const Color radicalRed2 = Color(0xFFFF647C);

//Pink
const Color pink = Color(0xFFCE8ABC);

//St Patricks Blue
const Color stPatricksBlue = Color(0xFFB1CEDE);
const Color gray = Color(0xFF889098);

//Light Salmon
const Color lightSalmon = Color(0xFFDCDBB8);

//Green
const Color green = Color(0xFF00CD50);

//Grey shade
const Color grey1100 = Color(0xFFFFFFFF);
const Color grey1000 = Color(0xFFF2F8F8);
const Color grey900 = Color(0xFFD7EAEA);
const Color grey800 = Color(0xFFBCDCDC);
const Color grey700 = Color(0xFFA1CECE);
const Color grey600 = Color(0xFF79B9B9);
const Color grey500 = Color(0xFF54A0A0);
const Color grey400 = Color(0xFF386B6B);
const Color grey300 = Color(0xFF234343);
const Color grey200 = Color(0xFF152929);
const Color grey100 = Color(0xFF010202);

extension CustomColorTheme on ThemeData {
  //text
  Color get color1 => brightness == Brightness.light ? grey700 : grey500;
  Color get color2 => brightness == Brightness.light ? grey800 : grey400;
  Color get color3 => brightness == Brightness.light ? grey900 : grey300;
  Color get color4 => brightness == Brightness.light ? grey1000 : grey200;
  Color get color7 => brightness == Brightness.light ? grey200 : grey1000;
  Color get color8 => brightness == Brightness.light ? grey300 : grey900;
  Color get color9 => brightness == Brightness.light ? grey400 : grey800;
  Color get color10 => brightness == Brightness.light ? grey500 : grey700;
  Color get color11 => brightness == Brightness.light ? grey1100 : grey100;
  Color get color12 => brightness == Brightness.light ? grey100 : grey1100;
  Color get color13 => brightness == Brightness.light ? primary : corn1;
  Color get color14 => brightness == Brightness.light ? grey1100 : Colors.black;
  LinearGradient get linearGradientCustome => brightness == Brightness.light
      ? const LinearGradient(colors: [
          grey100,
          grey100,
        ])
      : LinearGradient(colors: [
          const Color(0xFFCFE1FD).withOpacity(0.9),
          const Color(0xFFFFFDE1).withOpacity(0.9),
        ]);

  LinearGradient get colorLinearBottom => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromRGBO(31, 41, 51, 0),
          Color.fromRGBO(31, 41, 51, 0.1),
          Color.fromRGBO(31, 41, 51, 0.1),
          Color.fromRGBO(31, 41, 51, 0.1),
          Color.fromRGBO(31, 41, 51, 0.1),
          grey100
        ],
      );

  LinearGradient get colorLinearTop => const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Color.fromRGBO(31, 41, 51, 0),
          Color.fromRGBO(31, 41, 51, 0.1),
          Color.fromRGBO(31, 41, 51, 0.1),
          Color.fromRGBO(31, 41, 51, 0.1),
          Color.fromRGBO(31, 41, 51, 0.1),
          grey200
        ],
      );
  LinearGradient get colorLinearBottom2 => LinearGradient(
        end: Alignment.topCenter,
        begin: Alignment.bottomCenter,
        colors: [
          grey100.withOpacity(1),
          grey100.withOpacity(0),
        ],
      );
  LinearGradient get colorLinearBottom3 => LinearGradient(
        end: Alignment.topCenter,
        begin: Alignment.bottomCenter,
        colors: [
          grey100.withOpacity(1),
          const Color(0xFF000000).withOpacity(0),
        ],
      );
  LinearGradient get colorLinearBottom4 => LinearGradient(
        end: Alignment.bottomCenter,
        begin: Alignment.topCenter,
        colors: [
          const Color(0xFF106AF3).withOpacity(0.5),
          const Color(0xFF106AF3).withOpacity(0),
        ],
      );
  LinearGradient get colorLinear => LinearGradient(
        end: Alignment.centerRight,
        begin: Alignment.centerLeft,
        colors: [
          const Color(0xFFDFCEEC).withOpacity(0.9),
          const Color(0xFF8639F5).withOpacity(0.9),
          const Color(0xFF73F7E5).withOpacity(0.9),
        ],
      );
}
