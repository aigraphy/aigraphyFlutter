import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/widget/ads_applovin_banner.dart';
import '../../common/widget/animation_click.dart';
import '../widget/gift_widget.dart';
import '../widget/image_opacity.dart';

class ImageFullScreen extends StatefulWidget {
  const ImageFullScreen({super.key, required this.url});
  final String url;

  @override
  State<ImageFullScreen> createState() => _ImageFullScreenState();
}

class _ImageFullScreenState extends State<ImageFullScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: isIOS
          ? const SizedBox()
          : const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: AdsApplovinBanner(),
            ),
      floatingActionButton: const GiftWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      body: Padding(
        padding: const EdgeInsets.only(top: 64),
        child: Stack(
          children: [
            ImageOpacity(
              child: PhotoView(
                minScale: PhotoViewComputedScale.contained * 0.8,
                backgroundDecoration: const BoxDecoration(color: grey100),
                imageProvider: CachedNetworkImageProvider(
                  widget.url,
                ),
              ),
            ),
            Positioned(
              child: AnimationClick(
                function: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(left: 24, bottom: 32),
                  decoration: BoxDecoration(
                      color: grey200, borderRadius: BorderRadius.circular(48)),
                  child: Image.asset(
                    icClose,
                    width: 20,
                    height: 20,
                    color: grey1100,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
