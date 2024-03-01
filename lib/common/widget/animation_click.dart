import 'package:flutter/material.dart';

class AnimationClick extends StatefulWidget {
  const AnimationClick(
      {Key? key,
      required this.child,
      this.function,
      this.opacity = 0.75,
      this.disabled = false})
      : super(key: key);
  final Widget child;
  final Function? function;
  final double opacity;
  final bool disabled;
  @override
  _AnimationClickState createState() => _AnimationClickState();
}

class _AnimationClickState extends State<AnimationClick> {
  bool _visible = true;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _visible = false;
        });
        Future<dynamic>.delayed(const Duration(milliseconds: 100))
            .whenComplete(() {
          setState(() {
            _visible = true;
            if (widget.function != null) {
              widget.function!();
            }
          });
        });
      },
      child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.6,
          duration: const Duration(milliseconds: 100),
          child: widget.child),
    );
  }
}
