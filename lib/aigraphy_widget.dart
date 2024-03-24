import 'package:flutter/material.dart';

import '../translations/export_lang.dart';
import 'config/config_color.dart';
import 'config/config_font_styles.dart';
import 'config/config_image.dart';
import 'widget/click_widget.dart';

mixin AigraphyWidget {
  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static Future<void> showDialogDelAccount(String title, String subTitle,
      {required BuildContext context, Function()? remove}) async {
    showDialog<dynamic>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: spaceCadet,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: style4(color: white),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: Text(
                    subTitle,
                    textAlign: TextAlign.center,
                    style: style7(color: white),
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
                            backgroundColor: blackCoral,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            side: const BorderSide(color: blackCoral)),
                        child: Text(LocaleKeys.no.tr(),
                            textAlign: TextAlign.center,
                            style: style6(color: white)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AigraphyWidget.buttonCustom(
                          context: context,
                          input: LocaleKeys.yes.tr(),
                          bgColor: red2,
                          borderColor: red2,
                          textColor: white,
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

  static PreferredSizeWidget createAppBar(
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
      backgroundColor: backgroundColor ?? black,
      leading: hasLeading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClickWidget(
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
                        arrowLeft,
                        color: arrowColor ?? white,
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
                  ? style6(color: white, fontWeight: '700')
                  : style6(color: colorTitle, fontWeight: '700'),
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
                            const Icon(
                              Icons.add,
                              color: white,
                              size: 24,
                            ))
                  ],
                ),
              )
            : const SizedBox()
      ],
    );
  }

  static Widget buttonCustom(
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
    return ClickWidget(
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
              vertical: vertical ?? 16, horizontal: horizontal ?? 0),
          side: BorderSide(color: borderColor ?? white),
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
                style: style6(context: context, color: textColor),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        input!,
                        textAlign: TextAlign.center,
                        style: style6(context: context, color: textColor),
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

  static Widget buttonGradient(
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
    return ClickWidget(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: Theme.of(context).linerPimary),
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
                  style: style7(
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
                                      style: style5(
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
                                style:
                                    style6(context: context, color: textColor),
                              ),
                            ],
                          );
                  },
                ),
        ),
      ),
    );
  }

  static Widget buttonGradientAfter(
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
    return ClickWidget(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: Theme.of(context).linerPimary),
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
                  style: style7(
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
                                      style: style5(
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
                                style:
                                    style6(context: context, color: textColor),
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

  static Widget option(String icon,
      {Color color = spaceCadet, Color iconColor = white}) {
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

  static Widget countSwap(bool isMax, int countSwap) {
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
                  color: spaceCadet, borderRadius: BorderRadius.circular(16)),
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
                      style: style12(color: white),
                    ),
                  )
                ],
              ),
            ));
  }

  static Widget createIndicator(
      {required BuildContext context, int? currentImage, int? lengthImage}) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(lengthImage!, (index) {
          return AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: index == currentImage ? 8 : 8,
              width: index == currentImage ? 8 : 8,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  color: index == currentImage ? white : blackCoral));
        }));
  }
}
