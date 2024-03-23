import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieCustom extends StatefulWidget {
  const LottieCustom({super.key, required this.lottie, this.height});
  final String lottie;
  final double? height;
  @override
  State<LottieCustom> createState() => _LottieCustomState();
}

class _LottieCustomState extends State<LottieCustom>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      widget.lottie,
      controller: _controller,
      height: widget.height,
      onLoaded: (composition) {
        _controller
          ..duration = composition.duration
          ..repeat(reverse: true);
      },
    );
  }
}
