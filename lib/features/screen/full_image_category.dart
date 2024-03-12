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
import '../../common/bloc/set_user_pro/set_user_pro_bloc.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/models/category_model.dart';
import '../../common/models/image_category_model.dart';
import '../../common/route/routes.dart';
import '../../common/widget/ads_native_applovin_normal.dart';
import '../../common/widget/animation_click.dart';
import '../../translations/export_lang.dart';
import '../bloc/full_image_cate/full_image_cate_bloc.dart';
import '../bloc/generate_image/bloc_generate_image.dart';
import '../bloc/set_image_swap/set_image_swap_bloc.dart';
import '../bloc/trending/trending_bloc.dart';
import '../widget/dotted_image.dart';
import '../widget/go_pro_logo.dart';
import '../widget/image_opacity.dart';
import '../widget/loading_img_full.dart';
import '../widget/recent_face.dart';
import 'price_first_time.dart';
import 'step_three.dart';

class FullImageCategory extends StatefulWidget {
  const FullImageCategory({super.key, required this.categoryModel});
  final CategoryModel categoryModel;

  @override
  State<FullImageCategory> createState() => _FullImageCategoryState();
}

class _FullImageCategoryState extends State<FullImageCategory> {
  int _imgSwapIndex = 0;
  int _faceIndex = 0;
  bool showDelete = false;
  bool hasHandleFace = true;
  Uint8List? yourFace;
  String? pathImageSwap;
  String? pathYourFace;
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

  Future<void> setPhoto() async {
    setState(() {
      showDelete = false;
    });
    showModalBottomSheet<Map<String, dynamic>>(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: grey200,
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
          // AdLovinUtils().showAdIfReady();
          await uploadFace(context, yourFace);
          EasyLoading.dismiss();
        }
      }
    });
  }

  Future<void> handleGenerate() async {
    // final userModel = context.read<UserBloc>().userModel!;
    // if (userModel.token >= TOKEN_SWAP) {
    if (context.read<RecentFaceBloc>().recentFaces.isEmpty) {
      BotToast.showText(text: LocaleKeys.pleaseAddYourFace.tr());
      return;
    }
    late String imageSwapTmpLink;
    late ImageCategoryModel imageCategoryModel;
    //handle image swap
    if (context.read<SetImageSwapCubit>().state != null) {
      imageCategoryModel = context.read<SetImageSwapCubit>().state!;
      imageSwapTmpLink = imageCategoryModel.image;
    } else {
      imageCategoryModel = widget.categoryModel.images[0];
      imageSwapTmpLink = imageCategoryModel.image;
    }

    if (!context.read<SetUserPro>().state && imageCategoryModel.isPro) {
      Navigator.of(context)
          .pushNamed(Routes.price_first_time, arguments: PriceFirstTime());
      return;
    }
    Uint8List? imageSwap;
    EasyLoading.show();
    // showInterApplovin(context, () {}, seconds: 5);
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
    // } else {
    //   showDialog<void>(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return const NotEnoughToken();
    //     },
    //   );
    // }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<FullImageCategoryBloc>().add(ResetFullImageCategory());
    context
        .read<FullImageCategoryBloc>()
        .add(FullImageCategoryFetched(categoryId: widget.categoryModel.id!));
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
    return Scaffold(
      appBar: AppWidget.createSimpleAppBar(
          context: context, title: widget.categoryModel.name),
      bottomNavigationBar: Container(
        padding:
            const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 16),
        decoration: const BoxDecoration(
            color: grey200,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
                              fadeInDuration: const Duration(milliseconds: 200),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                  Positioned(
                      bottom: -4,
                      right: -4,
                      child: Image.asset(ic_swap, width: 24, height: 24))
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppWidget.typeButtonGradientAfter(
                  context: context,
                  input: '${LocaleKeys.generate.tr()} -$TOKEN_SWAP',
                  bgColor: primary,
                  textColor: grey1100,
                  icon: token,
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
      body: BlocBuilder<FullImageCategoryBloc, FullImageCategoryState>(
          builder: (context, state) {
        switch (state.status) {
          case FullImageCategoryStatus.initial:
            return const Center(child: CupertinoActivityIndicator());
          case FullImageCategoryStatus.success:
            final maxCount = state.images.isNotEmpty
                ? state.images.fold(
                    0, (maxCount, image) => max(maxCount, image.countSwap))
                : 0;
            return ListView(
              controller: _scrollController,
              children: [
                !isIOS
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: AdsNativeApplovinNormal(),
                      )
                    : const SizedBox(height: 8),
                GridView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 3 / 4,
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8),
                  itemCount: state.images.length,
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
                              isMax, state.images[index].countSwap),
                          if (state.images[index].isPro)
                            const Positioned(
                                right: 4, top: 4, child: GoProLogo())
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          case FullImageCategoryStatus.failure:
            return Center(
                child: Text(LocaleKeys.failedToFetch.tr(),
                    style: subhead(color: grey800)));
        }
      }),
    );
  }
}
