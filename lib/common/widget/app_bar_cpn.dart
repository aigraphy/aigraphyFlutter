import 'package:flutter/material.dart';

class AppBarCpn extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCpn(
      {Key? key,
      this.size,
      this.child,
      this.center,
      this.right,
      this.color = Colors.transparent,
      this.bottom,
      this.function,
      this.left})
      : super(key: key);
  final Size? size;
  final Widget? child;
  final Widget? center;
  final Widget? right;
  final Color color;
  final Widget? bottom;
  final Widget? left;
  final Function()? function;

  @override
  Size get preferredSize => size ?? const Size.fromHeight(kToolbarHeight + 240);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(color: color),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 16,
            ),
            child: child ??
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        left ??
                            IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: Container()),
                        center ?? const SizedBox(),
                        right ?? const SizedBox(width: 24),
                      ],
                    ),
                  ],
                ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(color: color),
            child: bottom ?? const SizedBox(),
          )
        ],
      ),
    );
  }
}
