import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../common/constant/colors.dart';
import 'image_opacity.dart';

class LoadingImageFull extends StatefulWidget {
  const LoadingImageFull({Key? key, required this.link}) : super(key: key);
  final String link;
  @override
  State<LoadingImageFull> createState() => _LoadingImageFullState();
}

class _LoadingImageFullState extends State<LoadingImageFull>
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

    _colorTween = ColorTween(begin: grey100, end: grey200).animate(_controller);
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
        child: ImageOpacity(
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
