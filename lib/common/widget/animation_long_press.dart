import 'package:flutter/material.dart';

class AnimationLongPress extends StatefulWidget {
  const AnimationLongPress(
      {Key? key,
      required this.child,
      this.function,
      this.onTap,
      this.opacity = 0.5,
      this.disabled = false})
      : super(key: key);
  final Widget child;
  final Function? function;
  final Function? onTap;
  final double opacity;
  final bool disabled;
  @override
  _AnimationLongPressState createState() => _AnimationLongPressState();
}

class _AnimationLongPressState extends State<AnimationLongPress> {
  bool _visible = true;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          _visible = false;
        });
        Future<dynamic>.delayed(const Duration(milliseconds: 600))
            .whenComplete(() {
          setState(() {
            _visible = true;
            if (widget.function != null) {
              widget.function!();
            }
          });
        });
      },
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 300),
          child: widget.child),
    );
  }
}
