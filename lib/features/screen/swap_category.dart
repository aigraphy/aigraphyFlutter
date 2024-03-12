import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/widget_support.dart';
import '../../common/bloc/set_user_pro/set_user_pro_bloc.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/models/category_model.dart';
import '../../common/route/routes.dart';
import '../../common/widget/ads_native_applovin_medium.dart';
import '../../common/widget/animation_click.dart';
import '../../common/widget/app_bar_cpn.dart';
import '../../translations/export_lang.dart';
import '../bloc/list_categories/list_categories_bloc.dart';
import '../bloc/new_today/new_today_bloc.dart';
import '../bloc/set_index_category/set_index_category_bloc.dart';
import '../bloc/trending/trending_bloc.dart';
import '../widget/action_swap_category.dart';
import '../widget/gift_widget.dart';
import '../widget/go_pro.dart';
import '../widget/go_pro_logo.dart';
import '../widget/loading_img_full.dart';
import 'full_image_category.dart';
import 'price_first_time.dart';
import 'step_two.dart';

class SwapCategory extends StatefulWidget {
  const SwapCategory({super.key});

  @override
  State<SwapCategory> createState() => _SwapCategoryState();
}

class _SwapCategoryState extends State<SwapCategory>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  void _onScroll() {
    if (_isBottom) {
      context.read<ListCategoriesBloc>().add(ListCategoriesFetched());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) {
      return false;
    }
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final viewportWidth = _scrollController.position.viewportDimension;
    final remainingScroll = maxScroll - currentScroll;

    return remainingScroll <= viewportWidth * 0.1;
  }

  Widget category(
      int indexCategory, double height, CategoryModel categoryModel) {
    final maxCount = categoryModel.images.isNotEmpty
        ? categoryModel.images
            .fold(0, (maxCount, image) => max(maxCount, image.countSwap))
        : 0;
    return RefreshIndicator(
      onRefresh: () => Future.sync(() {
        refresh();
      }),
      child: ListView(
        children: [
          GridView.builder(
            padding:
                const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 3 / 4,
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16),
            itemCount: categoryModel.images.length,
            itemBuilder: (context, index) {
              final isMax = maxCount == categoryModel.images[index].countSwap &&
                  maxCount != 0;
              return AnimationClick(
                function: () {
                  if (!context.read<SetUserPro>().state &&
                      categoryModel.images[index].isPro) {
                    Navigator.of(context).pushNamed(Routes.price_first_time,
                        arguments: PriceFirstTime());
                  } else {
                    Navigator.of(context).pushNamed(Routes.step_two,
                        arguments: StepTwo(
                          isImgCate: true,
                          imageCate: categoryModel.images[index].image,
                        ));
                  }
                },
                child: Stack(
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: LoadingImageFull(
                            link: categoryModel.images[index].image)),
                    AppWidget.iconCount(
                        isMax, categoryModel.images[index].countSwap),
                    if (categoryModel.images[index].isPro)
                      const Positioned(right: 4, top: 4, child: GoProLogo())
                  ],
                ),
              );
            },
          ),
          categoryModel.images.length == IMAGE_SHOW_LIMIT
              ? AnimationClick(
                  function: () {
                    Navigator.of(context).pushNamed(Routes.full_image_cate,
                        arguments:
                            FullImageCategory(categoryModel: categoryModel));
                  },
                  child: Text('See All',
                      textAlign: TextAlign.center,
                      style: headline(color: grey700)),
                )
              : const SizedBox(),
          const SizedBox(height: 80)
        ],
      ),
    );
  }

  Widget newToday() {
    return BlocBuilder<NewTodayBloc, NewTodayState>(builder: (context, state) {
      switch (state.status) {
        case NewTodayStatus.success:
          return RefreshIndicator(
            onRefresh: () => Future.sync(() {
              refresh();
            }),
            child: GridView.builder(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 80),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 3 / 4,
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16),
              itemCount: state.images.length,
              itemBuilder: (context, index) {
                final maxCount = state.images.isNotEmpty
                    ? state.images.fold(
                        0, (maxCount, image) => max(maxCount, image.countSwap))
                    : 0;
                final isMax =
                    maxCount == state.images[index].countSwap && maxCount != 0;
                return AnimationClick(
                  function: () {
                    if (!context.read<SetUserPro>().state &&
                        state.images[index].isPro) {
                      Navigator.of(context).pushNamed(Routes.price_first_time,
                          arguments: PriceFirstTime());
                    } else {
                      Navigator.of(context).pushNamed(Routes.step_two,
                          arguments: StepTwo(
                            isImgCate: true,
                            imageCate: state.images[index].image,
                          ));
                    }
                  },
                  child: Stack(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: LoadingImageFull(
                              link: state.images[index].image)),
                      AppWidget.iconCount(isMax, state.images[index].countSwap),
                      if (state.images[index].isPro)
                        const Positioned(right: 4, top: 4, child: GoProLogo())
                    ],
                  ),
                );
              },
            ),
          );
        default:
          return const SizedBox();
      }
    });
  }

  Widget trending() {
    return BlocBuilder<TrendingBloc, TrendingState>(builder: (context, state) {
      switch (state.status) {
        case TrendingStatus.success:
          return RefreshIndicator(
            onRefresh: () => Future.sync(() {
              refresh();
            }),
            child: GridView.builder(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 80),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 3 / 4,
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16),
              itemCount: state.images.length,
              itemBuilder: (context, index) {
                final maxCount = state.images.isNotEmpty
                    ? state.images.fold(
                        0, (maxCount, image) => max(maxCount, image.countSwap))
                    : 0;
                final isMax =
                    maxCount == state.images[index].countSwap && maxCount != 0;
                return AnimationClick(
                  function: () {
                    if (!context.read<SetUserPro>().state &&
                        state.images[index].isPro) {
                      Navigator.of(context).pushNamed(Routes.price_first_time,
                          arguments: PriceFirstTime());
                    } else {
                      Navigator.of(context).pushNamed(Routes.step_two,
                          arguments: StepTwo(
                            isImgCate: true,
                            imageCate: state.images[index].image,
                          ));
                    }
                  },
                  child: Stack(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: LoadingImageFull(
                              link: state.images[index].image)),
                      AppWidget.iconCount(isMax, state.images[index].countSwap),
                      if (state.images[index].isPro)
                        const Positioned(right: 4, top: 4, child: GoProLogo())
                    ],
                  ),
                );
              },
            ),
          );
        default:
          return const SizedBox();
      }
    });
  }

  Widget listCategory() {
    return BlocBuilder<ListCategoriesBloc, ListCategoriesState>(
      builder: (context, state) {
        switch (state.status) {
          case ListCategoriesStatus.failure:
            return const SizedBox();
          case ListCategoriesStatus.success:
            if (state.categories.isEmpty) {
              return const SizedBox();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      return index - 2 >= state.categories.length
                          ? const Center(child: CupertinoActivityIndicator())
                          : AnimationClick(
                              function: () {
                                if (!context.read<SetUserPro>().state &&
                                    index != 0 &&
                                    index != 1 &&
                                    state.categories[index - 2].isPro) {
                                  Navigator.of(context).pushNamed(
                                      Routes.price_first_time,
                                      arguments: PriceFirstTime());
                                } else {
                                  context
                                      .read<SetIndexCategory>()
                                      .setIndex(index);
                                }
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(32),
                                        color: context
                                                    .watch<SetIndexCategory>()
                                                    .state ==
                                                index
                                            ? null
                                            : grey200,
                                        gradient: context
                                                    .watch<SetIndexCategory>()
                                                    .state ==
                                                index
                                            ? Theme.of(context).colorLinear
                                            : null),
                                    child: Center(
                                      child: Text(
                                        index == 0
                                            ? 'NEW TODAY'
                                            : index == 1
                                                ? 'TRENDING'
                                                : state
                                                    .categories[index - 2].name,
                                        style: footnote(
                                            color: grey1100, fontWeight: '700'),
                                      ),
                                    ),
                                  ),
                                  if (index != 0 &&
                                      index != 1 &&
                                      state.categories[index - 2].isPro)
                                    Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              color: corn1),
                                          padding: const EdgeInsets.all(4),
                                          child: Image.asset(ic_pro,
                                              width: 12, height: 12),
                                        ))
                                ],
                              ),
                            );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemCount: state.hasReachedMax
                        ? state.categories.length + 2
                        : state.categories.length + 3),
              ),
            );
          case ListCategoriesStatus.initial:
            return const SizedBox();
        }
      },
    );
  }

  void refresh() {
    context.read<ListCategoriesBloc>().add(ResetListCategories());
    context.read<NewTodayBloc>().add(ResetNewToday());
    context.read<TrendingBloc>().add(ResetTrending());
    context.read<ListCategoriesBloc>().add(ListCategoriesFetched());
    context.read<NewTodayBloc>().add(NewTodayFetched());
    context.read<TrendingBloc>().add(TrendingFetched());
    context.read<SetIndexCategory>().setIndex(0);
  }

  @override
  bool get wantKeepAlive => true;

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
    super.build(context);
    final height = AppWidget.getHeightScreen(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBarCpn(
        left: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text('AIGraphy', style: headline(color: grey1100)),
        ),
        right: Row(
          children: [
            const GoPro(),
            Padding(
              padding: const EdgeInsets.only(right: 24, left: 12),
              child: AnimationClick(
                function: () {
                  Navigator.of(context).pushNamed(Routes.menu);
                },
                child: Image.asset(
                  circles_four,
                  width: 24,
                  height: 24,
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: const GiftWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      body: Column(
        children: [
          const ActionSwapCategory(),
          listCategory(),
          Expanded(
            child: BlocBuilder<ListCategoriesBloc, ListCategoriesState>(
              builder: (context, state) {
                switch (state.status) {
                  case ListCategoriesStatus.failure:
                    return Center(
                        child: Text(LocaleKeys.failedToFetch.tr(),
                            style: subhead(color: grey800)));
                  case ListCategoriesStatus.success:
                    if (state.categories.isEmpty) {
                      return Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(LocaleKeys.noCategoriesFound.tr(),
                              style: subhead(color: grey800)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: AdsNativeApplovinMedium(),
                          )
                        ],
                      ));
                    }
                    return IndexedStack(
                      index: context.watch<SetIndexCategory>().state,
                      children:
                          List.generate(state.categories.length + 2, (index) {
                        return index == 0
                            ? newToday()
                            : index == 1
                                ? trending()
                                : category(index - 2, height,
                                    state.categories[index - 2]);
                      }),
                    );

                  case ListCategoriesStatus.initial:
                    return const Center(child: CupertinoActivityIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
