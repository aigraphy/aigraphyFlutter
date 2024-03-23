import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config/config_color.dart';
import 'opacity_widget.dart';

class CachedFace extends StatefulWidget {
  const CachedFace({Key? key, required this.link, this.radius})
      : super(key: key);
  final String link;
  final double? radius;
  @override
  State<CachedFace> createState() => _CachedFaceState();
}

class _CachedFaceState extends State<CachedFace>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _colorTween;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _colorTween =
        ColorTween(begin: black, end: spaceCadet).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius ?? 10),
        child: OpacityWidget(
          child: CachedNetworkImage(
            imageUrl: widget.link,
            fit: BoxFit.cover,
            width: 64,
            height: 64,
            progressIndicatorBuilder: (context, url, progress) {
              return AnimatedBuilder(
                animation: _colorTween,
                builder: (context, child) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.radius ?? 10),
                    color: _colorTween.value,
                  ),
                  width: 64,
                  height: 64,
                ),
              );
            },
            fadeOutDuration: const Duration(milliseconds: 200),
            fadeInDuration: const Duration(milliseconds: 200),
          ),
        ));
  }
}
