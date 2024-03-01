import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../common/constant/colors.dart';
import 'image_opacity.dart';

class LoadingImageCategory extends StatefulWidget {
  const LoadingImageCategory({Key? key, required this.link}) : super(key: key);
  final String link;
  @override
  State<LoadingImageCategory> createState() => _LoadingImageCategoryState();
}

class _LoadingImageCategoryState extends State<LoadingImageCategory>
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
        borderRadius: BorderRadius.circular(12),
        child: ImageOpacity(
          child: CachedNetworkImage(
            imageUrl: widget.link,
            fit: BoxFit.cover,
            width: 160,
            height: 240,
            progressIndicatorBuilder: (context, url, progress) {
              return AnimatedBuilder(
                animation: _colorTween,
                builder: (context, child) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _colorTween.value,
                  ),
                  width: 160,
                  height: 240,
                ),
              );
            },
            fadeOutDuration: const Duration(milliseconds: 200),
            fadeInDuration: const Duration(milliseconds: 200),
          ),
        ));
  }
}
