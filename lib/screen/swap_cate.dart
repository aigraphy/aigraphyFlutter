import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../translations/export_lang.dart';
import '../bloc/list_categories/list_categories_bloc.dart';
import '../bloc/new_today/new_today_bloc.dart';
import '../bloc/set_index_category/set_index_category_bloc.dart';
import '../bloc/set_user_pro/set_user_pro_bloc.dart';
import '../bloc/trending/trending_bloc.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../config_model/cate_model.dart';
import '../config_router/name_router.dart';
import '../widget/appbar_custom.dart';
import '../widget/cached_img_full.dart';
import '../widget/click_widget.dart';
import '../widget/go_pro.dart';
import '../widget/go_pro_logo.dart';
import '../widget/native_medium_ads.dart';
import '../widget/offer_first_time.dart';
import '../widget_helper.dart';
import 'full_img_cate.dart';
import 'iap_first_time.dart';
import 'select_face.dart';

class SwapCate extends StatefulWidget {
  const SwapCate({super.key});

  @override
  State<SwapCate> createState() => _SwapCateState();
}

class _SwapCateState extends State<SwapCate>
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

  Widget category(int indexCategory, double height, CateModel categoryModel) {
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
              return ClickWidget(
                function: () {
                  if (!context.read<SetUserPro>().state &&
                      categoryModel.images[index].isPro) {
                    Navigator.of(context).pushNamed(Routes.iap_first_time,
                        arguments: IAPFirstTime());
                  } else {
                    Navigator.of(context).pushNamed(Routes.select_face,
                        arguments: SelectFace(
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
                        child: CachedImgFull(
                            link: categoryModel.images[index].image)),
                    AigraphyWidget.iconCount(
                        isMax, categoryModel.images[index].countSwap),
                    if (categoryModel.images[index].isPro)
                      const Positioned(right: 4, top: 4, child: GoProLogo())
                  ],
                ),
              );
            },
          ),
          categoryModel.images.length == IMAGE_SHOW_LIMIT
              ? ClickWidget(
                  function: () {
                    Navigator.of(context).pushNamed(Routes.full_img_cate,
                        arguments: FullImgCate(categoryModel: categoryModel));
                  },
                  child: Text('See All',
                      textAlign: TextAlign.center,
                      style: style6(color: whiteSmoke)),
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
                return ClickWidget(
                  function: () {
                    if (!context.read<SetUserPro>().state &&
                        state.images[index].isPro) {
                      Navigator.of(context).pushNamed(Routes.iap_first_time,
                          arguments: IAPFirstTime());
                    } else {
                      Navigator.of(context).pushNamed(Routes.select_face,
                          arguments: SelectFace(
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
                          child:
                              CachedImgFull(link: state.images[index].image)),
                      AigraphyWidget.iconCount(
                          isMax, state.images[index].countSwap),
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
                return ClickWidget(
                  function: () {
                    if (!context.read<SetUserPro>().state &&
                        state.images[index].isPro) {
                      Navigator.of(context).pushNamed(Routes.iap_first_time,
                          arguments: IAPFirstTime());
                    } else {
                      Navigator.of(context).pushNamed(Routes.select_face,
                          arguments: SelectFace(
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
                          child:
                              CachedImgFull(link: state.images[index].image)),
                      AigraphyWidget.iconCount(
                          isMax, state.images[index].countSwap),
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
                          : ClickWidget(
                              function: () {
                                if (!context.read<SetUserPro>().state &&
                                    index != 0 &&
                                    index != 1 &&
                                    state.categories[index - 2].isPro) {
                                  Navigator.of(context).pushNamed(
                                      Routes.iap_first_time,
                                      arguments: IAPFirstTime());
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
                                            : spaceCadet,
                                        gradient: context
                                                    .watch<SetIndexCategory>()
                                                    .state ==
                                                index
                                            ? Theme.of(context).linerPimary
                                            : null),
                                    child: Center(
                                      child: Text(
                                        index == 0
                                            ? 'NEW TODAY'
                                            : index == 1
                                                ? 'TRENDING'
                                                : state
                                                    .categories[index - 2].name,
                                        style: style10(
                                            color: white, fontWeight: '700'),
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
                                              color: yellow1),
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
    final height = AigraphyWidget.getHeightScreen(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBarCustom(
        left: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text('AIGraphy', style: style6(color: white)),
        ),
        right: Row(
          children: [
            const GoPro(),
            Padding(
              padding: const EdgeInsets.only(right: 24, left: 12),
              child: ClickWidget(
                function: () {
                  Navigator.of(context).pushNamed(Routes.settings);
                },
                child: Image.asset(
                  setting,
                  width: 24,
                  height: 24,
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: const OfferFirstTime(),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      body: Column(
        children: [
          listCategory(),
          Expanded(
            child: BlocBuilder<ListCategoriesBloc, ListCategoriesState>(
              builder: (context, state) {
                switch (state.status) {
                  case ListCategoriesStatus.failure:
                    return Center(
                        child: Text(LocaleKeys.failedToFetch.tr(),
                            style: style9(color: cultured)));
                  case ListCategoriesStatus.success:
                    if (state.categories.isEmpty) {
                      return Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(LocaleKeys.noCategoriesFound.tr(),
                              style: style9(color: cultured)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: NativeMediumAds(),
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
