import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:graphql/client.dart';
import 'package:shimmer/shimmer.dart';

import '../common/constant/colors.dart';
import '../common/constant/helper.dart';
import '../common/constant/images.dart';
import '../common/constant/styles.dart';
import '../common/graphql/config.dart';
import '../common/graphql/mutations.dart';
import '../common/route/routes.dart';
import '../common/widget/animation_click.dart';
import '../translations/export_lang.dart';

mixin AppWidget {
  static double getHeightScreen(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getWidthScreen(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static Future<void> showLoading({required BuildContext context}) async {
    showDialog<dynamic>(
      context: context,
      barrierDismissible: false,
      barrierColor: grey600,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async => false,
            child: const CupertinoActivityIndicator(
              animating: true,
            ));
      },
    );
  }

  static Widget loadImage(
      BuildContext context, Widget child, ImageChunkEvent? loadingProgress,
      {double? height, double? width}) {
    if (loadingProgress == null) {
      return child;
    }
    return Shimmer.fromColors(
      baseColor: grey200,
      highlightColor: grey400,
      child: Container(
        height: height ?? 250,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: grey200,
        ),
      ),
    );
  }

  static Future<void> showDialogCustom(String title, String subTitle,
      {required BuildContext context, Function()? remove}) async {
    showDialog<dynamic>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: grey200,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: title3(color: Theme.of(context).color12),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: Text(
                    subTitle,
                    textAlign: TextAlign.center,
                    style: body(color: Theme.of(context).color12),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: grey300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            side: const BorderSide(color: grey300)),
                        child: Text(LocaleKeys.no.tr(),
                            textAlign: TextAlign.center,
                            style: headline(color: Theme.of(context).color12)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppWidget.typeButtonStartAction(
                          context: context,
                          input: LocaleKeys.yes.tr(),
                          bgColor: radicalRed2,
                          borderColor: radicalRed2,
                          textColor: Theme.of(context).color12,
                          vertical: 14,
                          onPressed: () {
                            remove!();
                          }),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static PreferredSizeWidget createSimpleAppBar(
      {required BuildContext context,
      bool hasPop = true,
      Color? backgroundColor,
      bool hasLeading = true,
      String? title,
      Widget? action,
      Color? colorTitle,
      Color? arrowColor,
      Function()? onTap,
      Function()? onBack}) {
    return AppBar(
      elevation: 0,
      backgroundColor: backgroundColor ?? Theme.of(context).color11,
      leading: hasLeading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimationClick(
                  child: GestureDetector(
                      onTap: () {
                        if (hasPop) {
                          if (onBack != null) {
                            onBack();
                          } else {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      child: Image.asset(
                        icArrowLeft,
                        color: arrowColor ?? Theme.of(context).color12,
                        width: 24,
                        height: 24,
                      )),
                ),
              ],
            )
          : const SizedBox(),
      centerTitle: true,
      title: title == null
          ? null
          : Text(
              title,
              style: colorTitle == null
                  ? headline(
                      color: Theme.of(context).color12, fontWeight: '700')
                  : headline(color: colorTitle, fontWeight: '700'),
            ),
      actions: [
        onTap != null
            ? Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: onTap,
                        icon: action ??
                            Icon(
                              Icons.add,
                              color: Theme.of(context).color12,
                              size: 24,
                            ))
                  ],
                ),
              )
            : const SizedBox()
      ],
    );
  }

  static Widget typeButtonStartAction(
      {double? fontSize,
      required BuildContext context,
      double? height,
      double? vertical,
      double? horizontal,
      Function()? onPressed,
      Color? bgColor,
      Color? borderColor,
      double miniSizeHorizontal = double.infinity,
      Color? textColor,
      String? input,
      FontWeight? fontWeight,
      double borderRadius = 32,
      double sizeAsset = 24,
      Color? colorAsset,
      String? icon}) {
    return AnimationClick(
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
              vertical: vertical ?? 16, horizontal: horizontal ?? 0),
          side: BorderSide(color: borderColor ?? Theme.of(context).color12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius)),
          backgroundColor: bgColor,
          minimumSize: Size(miniSizeHorizontal, 0),
        ),
        onPressed: onPressed,
        child: icon == null
            ? Text(
                input!,
                textAlign: TextAlign.center,
                style: headline(context: context, color: textColor),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        input!,
                        textAlign: TextAlign.center,
                        style: headline(context: context, color: textColor),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                          child: Image.asset(
                        icon,
                        width: sizeAsset,
                        height: sizeAsset,
                        color: colorAsset,
                      )),
                    ],
                  );
                },
              ),
      ),
    );
  }

  static Widget typeButtonStartAction2(
      {double? fontSize,
      required BuildContext context,
      double? height,
      double? vertical,
      double? horizontal,
      Function()? onPressed,
      Color? bgColor,
      Color? borderColor,
      double miniSizeHorizontal = double.infinity,
      Color? textColor,
      String? input,
      FontWeight? fontWeight,
      double borderRadius = 32,
      double sizeAsset = 16,
      Color? colorAsset,
      String? icon}) {
    return AnimationClick(
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
              vertical: vertical ?? 16, horizontal: horizontal ?? 0),
          side: BorderSide(color: borderColor ?? Theme.of(context).color12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius)),
          backgroundColor: bgColor,
          minimumSize: Size(miniSizeHorizontal, 0),
        ),
        onPressed: onPressed,
        child: icon == null
            ? Text(
                input!,
                textAlign: TextAlign.center,
                style: headline(context: context, color: textColor),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          child: Image.asset(
                        icon,
                        width: sizeAsset,
                        height: sizeAsset,
                        color: colorAsset,
                      )),
                      const SizedBox(width: 8),
                      Text(
                        input!,
                        textAlign: TextAlign.center,
                        style: headline(context: context, color: textColor),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  static Widget typeButtonGradient(
      {double? fontSize,
      required BuildContext context,
      double? height,
      double? vertical,
      double? horizontal,
      Function()? onPressed,
      Color? bgColor,
      Color? borderColor,
      double miniSizeHorizontal = double.infinity,
      Color? textColor,
      String? input,
      FontWeight? fontWeight,
      double borderRadius = 32,
      double sizeAsset = 24,
      Color? colorAsset,
      Widget? leading,
      String? icon}) {
    return AnimationClick(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: Theme.of(context).colorLinear),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
                vertical: vertical ?? 16, horizontal: horizontal ?? 0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius)),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            minimumSize: Size(miniSizeHorizontal, 0),
          ),
          onPressed: onPressed,
          child: icon == null
              ? Text(
                  input!,
                  textAlign: TextAlign.center,
                  style: body(
                      context: context, color: textColor, fontWeight: '700'),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return leading != null
                        ? Row(
                            children: [
                              leading,
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      input!,
                                      textAlign: TextAlign.center,
                                      style: title4(
                                          context: context, color: textColor),
                                    ),
                                    const SizedBox(width: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Image.asset(
                                        icon,
                                        width: sizeAsset,
                                        height: sizeAsset,
                                        color: colorAsset,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 48,
                              )
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  child: Image.asset(
                                icon,
                                width: sizeAsset,
                                height: sizeAsset,
                                color: colorAsset,
                              )),
                              const SizedBox(width: 8),
                              Text(
                                input!,
                                textAlign: TextAlign.center,
                                style: headline(
                                    context: context, color: textColor),
                              ),
                            ],
                          );
                  },
                ),
        ),
      ),
    );
  }

  static Widget typeButtonGradientAfter(
      {double? fontSize,
      required BuildContext context,
      double? height,
      double? vertical,
      double? horizontal,
      Function()? onPressed,
      Color? bgColor,
      Color? borderColor,
      double miniSizeHorizontal = double.infinity,
      Color? textColor,
      String? input,
      FontWeight? fontWeight,
      double borderRadius = 32,
      double sizeAsset = 24,
      Color? colorAsset,
      Widget? leading,
      String? icon}) {
    return AnimationClick(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: Theme.of(context).colorLinear),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
                vertical: vertical ?? 16, horizontal: horizontal ?? 0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius)),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            minimumSize: Size(miniSizeHorizontal, 0),
          ),
          onPressed: onPressed,
          child: icon == null
              ? Text(
                  input!,
                  textAlign: TextAlign.center,
                  style: body(
                      context: context, color: textColor, fontWeight: '700'),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return leading != null
                        ? Row(
                            children: [
                              leading,
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      input!,
                                      textAlign: TextAlign.center,
                                      style: title4(
                                          context: context, color: textColor),
                                    ),
                                    const SizedBox(width: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Image.asset(
                                        icon,
                                        width: sizeAsset,
                                        height: sizeAsset,
                                        color: colorAsset,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 48,
                              )
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                input!,
                                textAlign: TextAlign.center,
                                style: headline(
                                    context: context, color: textColor),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                  child: Image.asset(
                                icon,
                                width: sizeAsset,
                                height: sizeAsset,
                                color: colorAsset,
                              )),
                            ],
                          );
                  },
                ),
        ),
      ),
    );
  }

  static SnackBar customSnackBar(
      {required String content, Color? color, int? milliseconds}) {
    return SnackBar(
      duration: Duration(milliseconds: milliseconds ?? 800),
      backgroundColor: color ?? primary,
      content: Text(
        content,
        textAlign: TextAlign.center,
        style: body(color: grey1100),
      ),
    );
  }

  static BottomNavigationBarItem createItemNav(BuildContext context,
      String iconInactive, String iconActive, String label) {
    return BottomNavigationBarItem(
        activeIcon: Image.asset(
          iconActive,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
        ),
        icon: Image.asset(
          iconInactive,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
        ),
        label: label);
  }

  static Future<void> deleteUser() async {
    final User firebaseUser = FirebaseAuth.instance.currentUser!;
    final String? token = await firebaseUser.getIdToken();
    await Config.initializeClient(token!).value.mutate(MutationOptions(
        document: gql(Mutations.deleteUser()),
        variables: <String, dynamic>{'uuid': firebaseUser.uid}));
  }

  static Widget option(String icon,
      {Color color = grey200, Color iconColor = grey1100}) {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(32)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Image.asset(
          icon,
          width: 24,
          height: 24,
          color: iconColor,
        ));
  }

  static Widget iconCount(bool isMax, int countSwap) {
    return countSwap == 0
        ? const SizedBox()
        : Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: isMax
                  ? const EdgeInsets.only(top: 3, bottom: 3, right: 6, left: 4)
                  : const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: grey200, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  isMax
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 2, right: 4),
                          child: Image.asset(fire, height: 12, width: 12),
                        )
                      : const SizedBox(),
                  Padding(
                    padding: EdgeInsets.only(top: isMax ? 2 : 0),
                    child: Text(
                      '$countSwap',
                      style: caption2(color: grey1100),
                    ),
                  )
                ],
              ),
            ));
  }
}
