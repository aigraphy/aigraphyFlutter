import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/widget_support.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/widget/ads_native_applovin_normal.dart';
import '../../common/widget/animation_click.dart';
import '../bloc/new_today/new_today_bloc.dart';
import '../bloc/set_image_swap/set_image_swap_bloc.dart';
import 'loading_img_full.dart';

class FullImageNewToday extends StatefulWidget {
  const FullImageNewToday({super.key});

  @override
  State<FullImageNewToday> createState() => _FullImageNewTodayState();
}

class _FullImageNewTodayState extends State<FullImageNewToday> {
  int _imgSwapIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = context.read<NewTodayBloc>().state.images;
    final maxCount = images.isNotEmpty
        ? images.fold(0, (maxCount, image) => max(maxCount, image.countSwap))
        : 0;
    return ListView(
      children: [
        GridView.builder(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 3 / 4,
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8),
          itemCount: images.length >= 2 ? 2 : images.length,
          itemBuilder: (context, index) {
            final isMax = maxCount == images[index].countSwap && maxCount != 0;
            return AnimationClick(
              function: () {
                setState(() {
                  _imgSwapIndex = index;
                });
                context.read<SetImageSwapCubit>().setImageSwap(images[index]);
              },
              child: Stack(
                children: [
                  Container(
                      decoration: BoxDecoration(
                        border: _imgSwapIndex == index
                            ? Border.all(color: grey1100, width: 2)
                            : null,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: LoadingImageFull(link: images[index].image)),
                  AppWidget.iconCount(isMax, images[index].countSwap)
                ],
              ),
            );
          },
        ),
        !isIOS
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: AdsNativeApplovinNormal(),
              )
            : const SizedBox(height: 8),
        images.length > 2
            ? GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 3 / 4,
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8),
                itemCount: images.length - 2,
                itemBuilder: (context, ind) {
                  final int index = ind + 2;
                  final isMax =
                      maxCount == images[index].countSwap && maxCount != 0;
                  return AnimationClick(
                    function: () {
                      setState(() {
                        _imgSwapIndex = index;
                      });
                      context
                          .read<SetImageSwapCubit>()
                          .setImageSwap(images[index]);
                    },
                    child: Stack(
                      children: [
                        Container(
                            decoration: BoxDecoration(
                              border: _imgSwapIndex == index
                                  ? Border.all(color: grey1100, width: 2)
                                  : null,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: LoadingImageFull(link: images[index].image)),
                        AppWidget.iconCount(isMax, images[index].countSwap)
                      ],
                    ),
                  );
                },
              )
            : const SizedBox()
      ],
    );
  }
}
