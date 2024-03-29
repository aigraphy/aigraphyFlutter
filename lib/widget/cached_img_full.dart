import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config/config_color.dart';
import 'opacity_widget.dart';

class CachedImgFull extends StatefulWidget {
  const CachedImgFull({Key? key, required this.link}) : super(key: key);
  final String link;
  @override
  State<CachedImgFull> createState() => _CachedImgFullState();
}

class _CachedImgFullState extends State<CachedImgFull>
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
        borderRadius: BorderRadius.circular(14),
        child: OpacityWidget(
          child: CachedNetworkImage(
            imageUrl: widget.link,
            fit: BoxFit.cover,
            height: 300,
            width: double.infinity,
            progressIndicatorBuilder: (context, url, progress) {
              return AnimatedBuilder(
                animation: _colorTween,
                builder: (context, child) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: _colorTween.value,
                  ),
                  height: 300,
                  width: double.infinity,
                ),
              );
            },
            fadeOutDuration: const Duration(milliseconds: 200),
            fadeInDuration: const Duration(milliseconds: 200),
          ),
        ));
  }
}
