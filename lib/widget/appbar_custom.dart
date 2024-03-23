import 'package:flutter/material.dart';

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCustom(
      {Key? key,
      this.size,
      this.child,
      this.center,
      this.right,
      this.function,
      this.left})
      : super(key: key);
  final Size? size;
  final Widget? child;
  final Widget? center;
  final Widget? right;
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
            decoration: const BoxDecoration(color: Colors.transparent),
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
                                icon: const SizedBox()),
                        center ?? const SizedBox(),
                        right ?? const SizedBox(width: 24),
                      ],
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}
