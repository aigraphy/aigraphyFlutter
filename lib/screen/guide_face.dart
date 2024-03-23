import 'package:flutter/material.dart';

import '../../translations/export_lang.dart';
import '../aigraphy_widget.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_image.dart';
import '../widget/appbar_custom.dart';
import '../widget/click_widget.dart';
import '../widget/text_gradient.dart';

class GuideFace extends PageRouteBuilder {
  GuideFace()
      : super(
            pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) =>
                GuideFaceWidget());

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return SlideTransition(
      position:
          Tween<Offset>(begin: const Offset(0, 1), end: const Offset(.0, .0))
              .animate(controller!),
      child: GuideFaceWidget(),
    );
  }
}

class GuideFaceWidget extends StatelessWidget {
  GuideFaceWidget({super.key});

  final List<String> goods = [good_1, good_2, good_3, good_4, good_5];
  final List<String> bads = [bad_1, bad_2, bad_3, bad_4, bad_5];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        left: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: ClickWidget(
            function: () {
              Navigator.of(context).pop();
            },
            child: Image.asset(
              icClose,
              width: 20,
              height: 20,
              color: white,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        child: AigraphyWidget.typeButtonGradientAfter(
            context: context,
            input: LocaleKeys.yeahSwapNow.tr(),
            textColor: white,
            onPressed: () async {
              Navigator.of(context).pop();
            }),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextGradient(
              LocaleKeys.uploadClearFace.tr(),
              style: const TextStyle(
                  fontSize: 28,
                  height: 1.8,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'ClashGrotesk'),
              gradient: Theme.of(context).linerPimary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextGradient(
              LocaleKeys.forBestQuality.tr(),
              style: const TextStyle(
                  fontSize: 28,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'ClashGrotesk'),
              gradient: Theme.of(context).linerPimary,
            ),
          ),
          const SizedBox(height: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Row(
                  children: [
                    Image.asset(ic_good, width: 24, height: 24),
                    const SizedBox(width: 4),
                    Text(LocaleKeys.goodImage.tr(), style: style6(color: white))
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  LocaleKeys.portraitPhoto.tr(),
                  style: style9(color: cultured),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 90,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemBuilder: (context, index) => Stack(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(goods[index],
                                    width: 90, height: 90)),
                            Positioned(
                                bottom: 2,
                                right: 2,
                                child:
                                    Image.asset(ic_good, width: 24, height: 24))
                          ],
                        ),
                    separatorBuilder: (context, index) => const SizedBox(
                          width: 8,
                        ),
                    itemCount: goods.length),
              ),
              const SizedBox(height: 24),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: const BoxDecoration(color: spaceCadet),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Image.asset(ic_bad, width: 24, height: 24),
                      const SizedBox(width: 4),
                      Text(LocaleKeys.badImage.tr(),
                          style: style6(color: white))
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    LocaleKeys.photoAreBlurry.tr(),
                    style: style9(color: cultured),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemBuilder: (context, index) => Stack(
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(bads[index],
                                      width: 90, height: 90)),
                              Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Image.asset(ic_bad,
                                      width: 24, height: 24))
                            ],
                          ),
                      separatorBuilder: (context, index) => const SizedBox(
                            width: 8,
                          ),
                      itemCount: bads.length),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
