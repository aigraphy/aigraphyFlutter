import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/styles.dart';
import '../../common/widget/gradient_text.dart';
import '../../translations/export_lang.dart';
import 'image_opacity.dart';

class GuideRemove extends StatelessWidget {
  const GuideRemove({super.key});

  Widget image(String img) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ImageOpacity(
          child: CachedNetworkImage(
        imageUrl: img,
        height: 120,
        alignment: Alignment.topCenter,
        progressIndicatorBuilder: (context, url, progress) =>
            const CupertinoActivityIndicator(),
        fadeOutDuration: const Duration(milliseconds: 200),
        fadeInDuration: const Duration(milliseconds: 200),
        fit: BoxFit.cover,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: grey200,
      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GradientText(
                LocaleKeys.guideOption.tr(),
                style: const TextStyle(
                    fontSize: 24,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'SpaceGrotesk'),
                gradient: Theme.of(context).linearGradientCustome,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    LocaleKeys.originImage.tr(),
                    style: headline(color: grey1100),
                  ),
                  const Icon(Icons.arrow_right_alt_rounded, size: 24),
                  Text(LocaleKeys.newImage.tr(),
                      style: headline(color: grey1100))
                ],
              ),
            ),
            Text('1. ${LocaleKeys.human.tr()}',
                style: subhead(color: grey1100)),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  image(image1),
                  const Icon(Icons.arrow_right_alt_rounded, size: 24),
                  image(image1BG)
                ],
              ),
            ),
            Text('2. ${LocaleKeys.anime.tr()}',
                style: subhead(color: grey1100)),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  image(imageAnime),
                  const Icon(Icons.arrow_right_alt_rounded, size: 24),
                  image(imageAnimeBG)
                ],
              ),
            ),
            Text('3.${LocaleKeys.humanAndAnimal.tr()} ',
                style: subhead(color: grey1100)),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  image(image1),
                  const Icon(Icons.arrow_right_alt_rounded, size: 24),
                  image(imageHumanAnimalBG)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
