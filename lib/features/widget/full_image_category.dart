import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/widget_support.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/styles.dart';
import '../../common/models/category_model.dart';
import '../../common/widget/ads_native_applovin_normal.dart';
import '../../common/widget/animation_click.dart';
import '../../translations/export_lang.dart';
import '../bloc/full_image_cate/full_image_cate_bloc.dart';
import '../bloc/set_image_swap/set_image_swap_bloc.dart';
import 'loading_img_full.dart';

class FullImageCategory extends StatefulWidget {
  const FullImageCategory({super.key, required this.categoryModel});
  final CategoryModel categoryModel;

  @override
  State<FullImageCategory> createState() => _FullImageCategoryState();
}

class _FullImageCategoryState extends State<FullImageCategory> {
  int _imgSwapIndex = 0;
  final _scrollController = ScrollController();

  void _onScroll() {
    if (_isBottom) {
      context
          .read<FullImageCategoryBloc>()
          .add(FullImageCategoryFetched(categoryId: widget.categoryModel.id!));
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) {
      return false;
    }
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FullImageCategoryBloc, FullImageCategoryState>(
        builder: (context, state) {
      switch (state.status) {
        case FullImageCategoryStatus.initial:
          return const Center(child: CupertinoActivityIndicator());
        case FullImageCategoryStatus.success:
          final maxCount = state.images.isNotEmpty
              ? state.images
                  .fold(0, (maxCount, image) => max(maxCount, image.countSwap))
              : 0;
          return ListView(
            controller: _scrollController,
            children: [
              GridView.builder(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 3 / 4,
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8),
                itemCount: state.images.length >= 2 ? 2 : state.images.length,
                itemBuilder: (context, index) {
                  final isMax = maxCount == state.images[index].countSwap &&
                      maxCount != 0;
                  return AnimationClick(
                    function: () {
                      setState(() {
                        _imgSwapIndex = index;
                      });
                      context
                          .read<SetImageSwapCubit>()
                          .setImageSwap(state.images[index]);
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
                            child: LoadingImageFull(
                                link: state.images[index].image)),
                        AppWidget.iconCount(
                            isMax, state.images[index].countSwap)
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
              state.images.length > 2
                  ? GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 3 / 4,
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8),
                      itemCount: state.images.length - 2,
                      itemBuilder: (context, ind) {
                        final int index = ind + 2;
                        final isMax =
                            maxCount == state.images[index].countSwap &&
                                maxCount != 0;
                        return AnimationClick(
                          function: () {
                            setState(() {
                              _imgSwapIndex = index;
                            });
                            context
                                .read<SetImageSwapCubit>()
                                .setImageSwap(state.images[index]);
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
                                  child: LoadingImageFull(
                                      link: state.images[index].image)),
                              // ImageOpacity(
                              //   child: Container(
                              //     decoration: BoxDecoration(
                              //       border: _imgSwapIndex == index
                              //           ? Border.all(color: grey1100, width: 2)
                              //           : null,
                              //       borderRadius: BorderRadius.circular(16),
                              //     ),
                              //     child: ClipRRect(
                              //         borderRadius: BorderRadius.circular(14),
                              //         child: CachedNetworkImage(
                              //           imageUrl: state.images[index].image,
                              //           fit: BoxFit.cover,
                              //           fadeOutDuration:
                              //               const Duration(milliseconds: 200),
                              //           fadeInDuration:
                              //               const Duration(milliseconds: 200),
                              //         )),
                              //   ),
                              // ),
                              AppWidget.iconCount(
                                  isMax, state.images[index].countSwap)
                            ],
                          ),
                        );
                      },
                    )
                  : const SizedBox()
            ],
          );
        case FullImageCategoryStatus.failure:
          return Center(
              child: Text(LocaleKeys.failedToFetch.tr(),
                  style: subhead(color: grey800)));
      }
    });
  }
}
