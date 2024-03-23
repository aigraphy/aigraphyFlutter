import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../config/config_color.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../widget/banner_ads.dart';
import '../widget/click_widget.dart';
import '../widget/offer_first_time.dart';
import '../widget/opacity_widget.dart';

class FullImgScreen extends StatefulWidget {
  const FullImgScreen({super.key, required this.url});
  final String url;

  @override
  State<FullImgScreen> createState() => _FullImgScreenState();
}

class _FullImgScreenState extends State<FullImgScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: isIOS
          ? const SizedBox()
          : const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: BannerAds(),
            ),
      floatingActionButton: const OfferFirstTime(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      body: Padding(
        padding: const EdgeInsets.only(top: 64),
        child: Stack(
          children: [
            OpacityWidget(
              child: PhotoView(
                minScale: PhotoViewComputedScale.contained * 0.8,
                backgroundDecoration: const BoxDecoration(color: black),
                imageProvider: CachedNetworkImageProvider(
                  widget.url,
                ),
              ),
            ),
            Positioned(
              child: ClickWidget(
                function: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(left: 24, bottom: 32),
                  decoration: BoxDecoration(
                      color: spaceCadet,
                      borderRadius: BorderRadius.circular(48)),
                  child: Image.asset(
                    icClose,
                    width: 20,
                    height: 20,
                    color: white,
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
