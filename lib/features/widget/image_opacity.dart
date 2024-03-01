import 'package:flutter/material.dart';

class ImageOpacity extends StatefulWidget {
  const ImageOpacity({super.key, required this.child, this.milliseconds = 700});
  final Widget child;
  final int milliseconds;
  @override
  State<ImageOpacity> createState() => _ImageOpacityState();
}

class _ImageOpacityState extends State<ImageOpacity>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: widget.milliseconds),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.addListener(() {
      setState(() {});
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _animation.value,
      child: widget.child,
    );
  }
}
