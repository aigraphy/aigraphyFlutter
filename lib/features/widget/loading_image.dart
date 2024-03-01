import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/widget_support.dart';
import '../../common/constant/colors.dart';
import '../../common/route/routes.dart';
import '../../common/widget/animation_click.dart';
import '../screen/image_full_screen.dart';
import 'image_opacity.dart';

class LoadingImage extends StatefulWidget {
  const LoadingImage({Key? key, required this.link}) : super(key: key);
  final String link;
  @override
  State<LoadingImage> createState() => _LoadingImageState();
}

class _LoadingImageState extends State<LoadingImage>
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
    final width = AppWidget.getWidthScreen(context);
    return AnimationClick(
      function: () async {
        Navigator.of(context).pushNamed(Routes.image_full,
            arguments: ImageFullScreen(url: widget.link));
      },
      child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ImageOpacity(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: width - 32,
                minHeight: 200,
              ),
              child: CachedNetworkImage(
                imageUrl: widget.link,
                fit: BoxFit.fitHeight,
                progressIndicatorBuilder: (context, url, progress) {
                  return AnimatedBuilder(
                    animation: _colorTween,
                    builder: (context, child) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: _colorTween.value,
                      ),
                      width: double.infinity,
                      height: 575,
                    ),
                  );
                },
                fadeOutDuration: const Duration(milliseconds: 200),
                fadeInDuration: const Duration(milliseconds: 200),
              ),
            ),
          )),
    );
  }
}
