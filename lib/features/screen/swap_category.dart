import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../app/widget_support.dart';
import '../../common/bloc/recent_face/bloc_recent_face.dart';
import '../../common/bloc/user/bloc_user.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/helper_ads/ads_lovin_utils.dart';
import '../../common/models/category_model.dart';
import '../../common/models/image_category_model.dart';
import '../../common/models/recent_face_model.dart';
import '../../common/route/routes.dart';
import '../../common/widget/ads_native_applovin_medium.dart';
import '../../common/widget/animation_click.dart';
import '../../common/widget/animation_long_press.dart';
import '../../common/widget/app_bar_cpn.dart';
import '../../common/widget/gradient_text.dart';
import '../../common/widget/open_slot.dart';
import '../../translations/export_lang.dart';
import '../bloc/full_image_cate/full_image_cate_bloc.dart';
import '../bloc/generate_image/bloc_generate_image.dart';
import '../bloc/list_categories/list_categories_bloc.dart';
import '../bloc/new_today/new_today_bloc.dart';
import '../bloc/set_image_swap/set_image_swap_bloc.dart';
import '../bloc/trending/trending_bloc.dart';
import '../widget/action_swap_category.dart';
import '../widget/dotted_image.dart';
import '../widget/full_image_category.dart';
import '../widget/full_image_new_today.dart';
import '../widget/full_image_trending.dart';
import '../widget/gift_widget.dart';
import '../widget/image_opacity.dart';
import '../widget/loading_img_category.dart';
import '../widget/not_enough_token.dart';
import '../widget/recent_face.dart';
import '../widget/token_widget.dart';
import 'step_three.dart';

class SwapCategory extends StatefulWidget {
  const SwapCategory({super.key});

  @override
  State<SwapCategory> createState() => _SwapCategoryState();
}

class _SwapCategoryState extends State<SwapCategory>
    with AutomaticKeepAliveClientMixin {
  Uint8List? yourFace;
  String? pathImageSwap;
  String? pathYourFace;
  String? imgSwapUrl;
  String? faceSwapUrl;
  bool showDelete = false;
  bool hasHandleFace = true;
  CategoryModel? categorySelected;
  bool showFullImageToday = false;
  bool showFullImageTrending = false;
  int _faceIndex = 0;
  int? _imgSwapIndex;
  int? _imgSwapTodayIndex;
  int? _imgSwapTrendingIndex;
  int _categoryIndex = 0;
  String? title;
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
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> setPhoto() async {
    setState(() {
      showDelete = false;
    });
    showModalBottomSheet<Map<String, dynamic>>(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: grey100,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return RecentFace(
            cropImage: true, handling: false, currentIndex: _faceIndex);
      },
      context: context,
    ).then((dynamic value) async {
      if (value != null) {
        if (value['index'] != null) {
          setState(() {
            _faceIndex = value['index'];
            hasHandleFace = true;
          });
        } else {
          EasyLoading.show();
          setState(() {
            hasHandleFace = false;
            yourFace = value['bytes'];
            pathYourFace = value['path'];
            _faceIndex = 0;
          });
          AdLovinUtils().showAdIfReady();
          await uploadFace(context, yourFace);
          EasyLoading.dismiss();
        }
      }
    });
  }

  Widget category(
      int indexCategory, double height, CategoryModel categoryModel) {
    final maxCount = categoryModel.images.isNotEmpty
        ? categoryModel.images
            .fold(0, (maxCount, image) => max(maxCount, image.countSwap))
        : 0;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(categoryModel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: title4(color: grey700))),
              AnimationClick(
                function: () {
                  setState(() {
                    _categoryIndex = indexCategory;
                    _imgSwapIndex = 0;
                    _imgSwapTodayIndex = null;
                    _imgSwapTrendingIndex = null;
                    title = categoryModel.name;
                    categorySelected = categoryModel;
                  });
                  context
                      .read<FullImageCategoryBloc>()
                      .add(ResetFullImageCategory());
                  context.read<FullImageCategoryBloc>().add(
                      FullImageCategoryFetched(categoryId: categoryModel.id!));
                },
                child: Text('See All', style: headline(color: grey700)),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 240,
            child: categoryModel.images.isNotEmpty
                ? ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemBuilder: (context, index) {
                      final isMax =
                          maxCount == categoryModel.images[index].countSwap &&
                              maxCount != 0;
                      return AnimationClick(
                        function: () {
                          setState(() {
                            _imgSwapIndex = index;
                            _imgSwapTodayIndex = null;
                            _imgSwapTrendingIndex = null;
                            _categoryIndex = indexCategory;
                          });
                        },
                        child: Stack(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  border: _categoryIndex == indexCategory &&
                                          _imgSwapIndex == index
                                      ? Border.all(color: grey1100, width: 2)
                                      : null,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: LoadingImageCategory(
                                    link: categoryModel.images[index].image)),
                            AppWidget.iconCount(
                                isMax, categoryModel.images[index].countSwap)
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemCount: categoryModel.images.length)
                : Center(
                    child: Text(
                      LocaleKeys.weWillUpdate.tr(),
                      style: subhead(color: grey800),
                    ),
                  ),
          ),
        )
      ],
    );
  }

  Widget newToday(double height, List<ImageCategoryModel> images) {
    final maxCount = images.isNotEmpty
        ? images.fold(0, (maxCount, image) => max(maxCount, image.countSwap))
        : 0;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text('New Today',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: title4(color: grey700))),
              AnimationClick(
                function: () {
                  setState(() {
                    title = 'New Today';
                    showFullImageToday = true;
                  });
                },
                child: Text('See All', style: headline(color: grey700)),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 240,
            child: images.isNotEmpty
                ? ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemBuilder: (context, index) {
                      final isMax =
                          maxCount == images[index].countSwap && maxCount != 0;
                      return AnimationClick(
                        function: () {
                          setState(() {
                            _imgSwapTodayIndex = index;
                            _imgSwapIndex = null;
                            _imgSwapTrendingIndex = null;
                          });
                        },
                        child: Stack(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  border: _imgSwapTodayIndex == index
                                      ? Border.all(color: grey1100, width: 2)
                                      : null,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: LoadingImageCategory(
                                    link: images[index].image)),
                            AppWidget.iconCount(isMax, images[index].countSwap)
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemCount: images.length > IMAGE_SHOW_LIMIT
                        ? IMAGE_SHOW_LIMIT
                        : images.length)
                : Center(
                    child: Text(
                      LocaleKeys.weWillUpdate.tr(),
                      style: subhead(color: grey800),
                    ),
                  ),
          ),
        )
      ],
    );
  }

  Widget trending(double height, List<ImageCategoryModel> images) {
    final maxCount = images.isNotEmpty
        ? images.fold(0, (maxCount, image) => max(maxCount, image.countSwap))
        : 0;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text('Trending',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: title4(color: grey700))),
              AnimationClick(
                function: () {
                  setState(() {
                    title = 'Trending';
                    showFullImageTrending = true;
                  });
                },
                child: Text('See All', style: headline(color: grey700)),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 240,
            child: images.isNotEmpty
                ? ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemBuilder: (context, index) {
                      final isMax =
                          maxCount == images[index].countSwap && maxCount != 0;
                      return AnimationClick(
                        function: () {
                          setState(() {
                            _imgSwapTrendingIndex = index;
                            _imgSwapIndex = null;
                            _imgSwapTodayIndex = null;
                          });
                        },
                        child: Stack(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  border: _imgSwapTrendingIndex == index
                                      ? Border.all(color: grey1100, width: 2)
                                      : null,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: LoadingImageCategory(
                                    link: images[index].image)),
                            AppWidget.iconCount(isMax, images[index].countSwap)
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemCount: images.length > IMAGE_SHOW_LIMIT
                        ? IMAGE_SHOW_LIMIT
                        : images.length)
                : Center(
                    child: Text(
                      LocaleKeys.weWillUpdate.tr(),
                      style: subhead(color: grey800),
                    ),
                  ),
          ),
        )
      ],
    );
  }

  Widget itemRecent(int index, RecentFaceModel recentFaceModel) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        AnimationLongPress(
          function: () {
            setState(() {
              showDelete = !showDelete;
            });
          },
          onTap: () async {
            setState(() {
              _faceIndex = index;
              hasHandleFace = true;
            });
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: _faceIndex == index
                    ? Border.all(color: grey1100, width: 2)
                    : null),
            child: ImageOpacity(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: recentFaceModel.face,
                  width: 64,
                  height: 64,
                  fadeOutDuration: const Duration(milliseconds: 200),
                  fadeInDuration: const Duration(milliseconds: 200),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        showDelete
            ? Positioned(
                right: -8,
                top: 0,
                child: AnimationClick(
                  function: () {
                    context.read<RecentFaceBloc>().add(
                        DeleteFace(recentFaceModel.id!, recentFaceModel.face));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        color: grey300),
                    child: Image.asset(
                      icClose,
                      width: 16,
                      height: 16,
                      color: grey1100,
                    ),
                  ),
                ))
            : const SizedBox()
      ],
    );
  }

  Widget recentFaces() {
    final recentsCount =
        context.watch<UserBloc>().userModel?.slotRecentFace ?? DEFAULT_SLOT;
    return TapRegion(
      onTapOutside: (tap) {
        setState(() {
          showDelete = false;
        });
      },
      child: SizedBox(
        height: 80,
        child: BlocBuilder<RecentFaceBloc, RecentFaceState>(
            builder: (context, state) {
          if (state is RecentFaceLoaded) {
            final List<RecentFaceModel> recentFaces = state.recentFaces;
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemCount: recentFaces.length >= recentsCount
                  ? recentsCount + 2
                  : recentsCount + 1,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemBuilder: (context, ind) {
                final int index = ind > 0 ? ind - 1 : ind;
                return ind == 0
                    ? AnimationClick(
                        function: setPhoto, child: const DottedImage(size: 64))
                    : index >= recentsCount
                        ? AnimationClick(
                            function: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return const OpenSlot();
                                },
                              );
                            },
                            child: Container(
                              width: 64,
                              height: 64,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                  color: grey200,
                                  border: Border.all(color: grey600),
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              child: Image.asset(lock, fit: BoxFit.cover),
                            ),
                          )
                        : index > recentFaces.length - 1
                            ? Container(
                                width: 64,
                                height: 64,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                    color: grey200,
                                    border: Border.all(color: grey600),
                                    borderRadius: BorderRadius.circular(10)),
                              )
                            : itemRecent(index, recentFaces[index]);
              },
            );
          }
          return AnimationClick(
              function: setPhoto, child: const DottedImage(size: 64));
        }),
      ),
    );
  }

  Widget listCategory(double height) {
    return BlocBuilder<ListCategoriesBloc, ListCategoriesState>(
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
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return index >= state.categories.length
                    ? const Center(child: CupertinoActivityIndicator())
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: category(index, height, state.categories[index]),
                      );
              },
              itemCount: state.hasReachedMax
                  ? state.categories.length
                  : state.categories.length + 1,
            );
          case ListCategoriesStatus.initial:
            return const Center(child: CupertinoActivityIndicator());
        }
      },
    );
  }

  Future<void> handleGenerate() async {
    final userModel = context.read<UserBloc>().userModel!;
    if (userModel.token >= TOKEN_SWAP) {
      if (context.read<RecentFaceBloc>().recentFaces.isEmpty) {
        BotToast.showText(text: LocaleKeys.pleaseAddYourFace.tr());
        return;
      }
      Uint8List? imageSwap;
      EasyLoading.show();
      showInterApplovin(context, () {}, seconds: 5);
      if (hasHandleFace) {
        //handle face
        final face = await getImage(
            context.read<RecentFaceBloc>().recentFaces[_faceIndex].face);
        final tempDirFace = await Directory.systemTemp.createTemp();
        final tempFileFace =
            File('${tempDirFace.path}/${DateTime.now().toIso8601String()}.jpg');

        await tempFileFace.writeAsBytes(face);
        yourFace = face;
        pathYourFace = tempFileFace.path;
      }
      if (yourFace == null) {
        EasyLoading.dismiss();
        BotToast.showText(text: LocaleKeys.pleaseChooseYourFace.tr());
        return;
      }

      late String imageSwapTmpLink;
      late ImageCategoryModel imageCategoryModel;
      //handle image swap
      if (context.read<SetImageSwapCubit>().state != null) {
        imageCategoryModel = context.read<SetImageSwapCubit>().state!;
        imageSwapTmpLink = imageCategoryModel.image;
      } else {
        imageCategoryModel = _imgSwapIndex == null
            ? _imgSwapTodayIndex != null
                ? context.read<NewTodayBloc>().state.images[_imgSwapTodayIndex!]
                : context
                    .read<TrendingBloc>()
                    .state
                    .images[_imgSwapTrendingIndex!]
            : context
                .read<ListCategoriesBloc>()
                .state
                .categories[_categoryIndex]
                .images[_imgSwapIndex!];
        imageSwapTmpLink = imageCategoryModel.image;
      }

      final imageSwapTmp = await getImage(imageSwapTmpLink);
      final tempDirImageSwap = await Directory.systemTemp.createTemp();
      final tempFileImageSwap = File(
          '${tempDirImageSwap.path}/${DateTime.now().toIso8601String()}.jpg');
      await tempFileImageSwap.writeAsBytes(imageSwapTmp);
      imageSwap = imageSwapTmp;
      pathImageSwap = tempFileImageSwap.path;
      context
          .read<TrendingBloc>()
          .add(TrendingCount(categoryModel: imageCategoryModel));
      context.read<GenerateImageBloc>().add(InitialGenerateImage(
          context: context,
          srcPath: pathImageSwap!,
          dstPath: pathYourFace!,
          handleToken: true));
      context.read<SetImageSwapCubit>().reset();
      EasyLoading.dismiss();
      Navigator.of(context).pushNamed(Routes.step_three,
          arguments: StepThree(
              dstPath: pathYourFace!,
              srcPath: pathImageSwap!,
              srcImage: imageSwap,
              isSwapCate: true,
              dstImage: yourFace!));
    } else {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return const NotEnoughToken();
        },
      );
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    checkHasAds();
    showDelete = false;
    showFullImageToday = false;
    showFullImageTrending = false;
    categorySelected = null;
    hasHandleFace = true;
    _imgSwapTodayIndex = 0;
    _imgSwapTrendingIndex = null;
    _imgSwapIndex = null;
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
      body: SizedBox(
        height: height,
        child: Stack(
          children: [
            Container(
              height: height / 2,
              decoration:
                  BoxDecoration(gradient: Theme.of(context).colorLinearBottom4),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: showFullImageToday ||
                        showFullImageTrending ||
                        categorySelected != null
                    ? AppWidget.createSimpleAppBar(
                        backgroundColor: const Color(0xFF106AF3).withOpacity(0),
                        context: context,
                        onBack: () {
                          setState(() {
                            categorySelected = null;
                            showFullImageToday = false;
                            showFullImageTrending = false;
                          });
                          context.read<SetImageSwapCubit>().reset();
                        },
                        title: title)
                    : AppBarCpn(
                        left: Padding(
                          padding: const EdgeInsets.only(left: 24),
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
                        ),
                        right: const TokenWidget(),
                      ),
                bottomNavigationBar: Container(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, top: 16, bottom: 8),
                  decoration: const BoxDecoration(
                      color: grey200,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AnimationClick(
                        function: () {
                          setPhoto();
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomCenter,
                          children: [
                            context.watch<RecentFaceBloc>().recentFaces.isEmpty
                                ? const DottedImage(size: 58)
                                : ImageOpacity(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(
                                        imageUrl: context
                                            .watch<RecentFaceBloc>()
                                            .recentFaces[_faceIndex]
                                            .face,
                                        width: 58,
                                        height: 58,
                                        fadeOutDuration:
                                            const Duration(milliseconds: 200),
                                        fadeInDuration:
                                            const Duration(milliseconds: 200),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                            Positioned(
                                bottom: -4,
                                right: -4,
                                child:
                                    Image.asset(ic_swap, width: 24, height: 24))
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppWidget.typeButtonStartAction(
                            context: context,
                            input: '${LocaleKeys.generate.tr()} -$TOKEN_SWAP',
                            bgColor: primary,
                            textColor: grey1100,
                            icon: token2,
                            sizeAsset: 16,
                            borderColor: primary,
                            borderRadius: 12,
                            onPressed: () async {
                              await handleGenerate();
                            }),
                      ),
                    ],
                  ),
                ),
                floatingActionButton: const GiftWidget(),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.miniEndFloat,
                body: categorySelected != null
                    ? FullImageCategory(categoryModel: categorySelected!)
                    : showFullImageToday || showFullImageTrending
                        ? showFullImageToday
                            ? const FullImageNewToday()
                            : const FullImageTrending()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const ActionSwapCategory(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 8),
                                child: GradientText(
                                  LocaleKeys.chooseImageSwap.tr(),
                                  style: const TextStyle(
                                      fontSize: 28,
                                      height: 1,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'SpaceGrotesk'),
                                  gradient:
                                      Theme.of(context).linearGradientCustome,
                                ),
                              ),
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: () => Future.sync(
                                    () {
                                      context
                                          .read<ListCategoriesBloc>()
                                          .add(ResetListCategories());
                                      context
                                          .read<NewTodayBloc>()
                                          .add(ResetNewToday());
                                      context
                                          .read<TrendingBloc>()
                                          .add(ResetTrending());
                                      context
                                          .read<ListCategoriesBloc>()
                                          .add(ListCategoriesFetched());
                                      context
                                          .read<NewTodayBloc>()
                                          .add(NewTodayFetched());
                                      context
                                          .read<TrendingBloc>()
                                          .add(TrendingFetched());
                                    },
                                  ),
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    child: Column(
                                      children: [
                                        BlocBuilder<NewTodayBloc,
                                                NewTodayState>(
                                            builder: (context, state) {
                                          switch (state.status) {
                                            case NewTodayStatus.success:
                                              return newToday(
                                                  height, state.images);
                                            default:
                                              return const SizedBox();
                                          }
                                        }),
                                        const SizedBox(height: 16),
                                        BlocBuilder<TrendingBloc,
                                                TrendingState>(
                                            builder: (context, state) {
                                          switch (state.status) {
                                            case TrendingStatus.success:
                                              return trending(
                                                  height, state.images);
                                            default:
                                              return const SizedBox();
                                          }
                                        }),
                                        const SizedBox(height: 16),
                                        listCategory(height),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
