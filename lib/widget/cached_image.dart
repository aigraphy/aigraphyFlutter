import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../aigraphy_widget.dart';
import '../config/config_color.dart';
import '../config_router/name_router.dart';
import '../screen/full_img_screen.dart';
import 'click_widget.dart';
import 'opacity_widget.dart';

class CachedImage extends StatefulWidget {
  const CachedImage({Key? key, required this.link}) : super(key: key);
  final String link;
  @override
  State<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage>
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
    final width = AigraphyWidget.getWidthScreen(context);
    return ClickWidget(
      function: () async {
        Navigator.of(context).pushNamed(Routes.full_img_screen,
            arguments: FullImgScreen(url: widget.link));
      },
      child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: OpacityWidget(
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
