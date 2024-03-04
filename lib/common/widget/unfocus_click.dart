import 'package:flutter/material.dart';

class UnfocusClick extends StatelessWidget {
  const UnfocusClick({Key? key, required this.child, this.onTap})
      : super(key: key);
  final Widget child;
  final Function? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
        FocusScope.of(context).unfocus();
      },
      child: child,
    );
  }
}
