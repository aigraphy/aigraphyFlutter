import 'package:flutter/material.dart';

class ClickWidget extends StatefulWidget {
  const ClickWidget(
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
  _ClickWidgetState createState() => _ClickWidgetState();
}

class _ClickWidgetState extends State<ClickWidget> {
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
