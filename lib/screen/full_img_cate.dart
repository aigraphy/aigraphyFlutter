import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../translations/export_lang.dart';
import '../aigraphy_widget.dart';
import '../bloc/all_img_cate/all_img_cate_bloc.dart';
import '../bloc/cate_trending/cate_trending_bloc.dart';
import '../bloc/current_img_swap/current_img_swap_bloc.dart';
import '../bloc/face/bloc_face.dart';
import '../bloc/set_user_pro/set_user_pro_bloc.dart';
import '../bloc/swap_img/bloc_swap_img.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../config_model/cate_model.dart';
import '../config_model/img_cate_model.dart';
import '../config_router/name_router.dart';
import '../widget/cached_img_full.dart';
import '../widget/choose_faces.dart';
import '../widget/click_widget.dart';
import '../widget/dotted_widget.dart';
import '../widget/go_pro_logo.dart';
import '../widget/native_normal_ads.dart';
import '../widget/opacity_widget.dart';
import 'final_result.dart';
import 'iap_first_time.dart';

class FullImgCate extends StatefulWidget {
  const FullImgCate({super.key, required this.categoryModel});
  final CateModel categoryModel;

  @override
  State<FullImgCate> createState() => _FullImgCateState();
}

class _FullImgCateState extends State<FullImgCate> {
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
          .read<AllImgCateBloc>()
          .add(AllImgCateFetched(categoryId: widget.categoryModel.id!));
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
      backgroundColor: spaceCadet,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ChooseFaces(
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
          await uploadFace(context, yourFace);
          EasyLoading.dismiss();
        }
      }
    });
  }

  Future<void> handleGenerate() async {
    if (context.read<FaceBloc>().faces.isEmpty) {
      BotToast.showText(text: LocaleKeys.pleaseAddYourFace.tr());
      return;
    }
    late String imageSwapTmpLink;
    late ImgCateModel imageCategoryModel;
    if (context.read<CurrentImgSwapCubit>().state != null) {
      imageCategoryModel = context.read<CurrentImgSwapCubit>().state!;
      imageSwapTmpLink = imageCategoryModel.image;
    } else {
      imageCategoryModel = widget.categoryModel.images[0];
      imageSwapTmpLink = imageCategoryModel.image;
    }

    if (!context.read<SetUserPro>().state && imageCategoryModel.isPro) {
      Navigator.of(context)
          .pushNamed(Routes.iap_first_time, arguments: IAPFirstTime());
      return;
    }
    Uint8List? imageSwap;
    EasyLoading.show();
    if (hasHandleFace) {
      final face =
          await getUint8List(context.read<FaceBloc>().faces[_faceIndex].face);
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

    final imageSwapTmp = await getUint8List(imageSwapTmpLink);
    final tempDirImageSwap = await Directory.systemTemp.createTemp();
    final tempFileImageSwap = File(
        '${tempDirImageSwap.path}/${DateTime.now().toIso8601String()}.jpg');
    await tempFileImageSwap.writeAsBytes(imageSwapTmp);
    imageSwap = imageSwapTmp;
    pathImageSwap = tempFileImageSwap.path;
    context
        .read<CateTrendingBloc>()
        .add(CateTrendingCount(categoryModel: imageCategoryModel));
    context.read<SwapImgBloc>().add(InitialSwapImg(
        context: context,
        srcPath: pathImageSwap!,
        dstPath: pathYourFace!,
        handleCoin: true));
    context.read<CurrentImgSwapCubit>().reset();
    EasyLoading.dismiss();
    Navigator.of(context).pushNamed(Routes.final_result,
        arguments: FinalResult(
            dstPath: pathYourFace!,
            srcPath: pathImageSwap!,
            srcImage: imageSwap,
            isSwapCate: true,
            dstImage: yourFace!));
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<AllImgCateBloc>().add(ResetAllImgCate());
    context
        .read<AllImgCateBloc>()
        .add(AllImgCateFetched(categoryId: widget.categoryModel.id!));
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
      appBar: AigraphyWidget.createAppBar(
          context: context, title: widget.categoryModel.name),
      bottomNavigationBar: Container(
        padding:
            const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 16),
        decoration: const BoxDecoration(
            color: spaceCadet,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClickWidget(
              function: () {
                setPhoto();
              },
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  context.watch<FaceBloc>().faces.isEmpty
                      ? const DottedWidget(size: 58)
                      : OpacityWidget(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: context
                                  .watch<FaceBloc>()
                                  .faces[_faceIndex]
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
              child: AigraphyWidget.buttonGradientAfter(
                  context: context,
                  input: '${LocaleKeys.generate.tr()} -$TOKEN_SWAP',
                  bgColor: blue,
                  textColor: white,
                  icon: coin,
                  sizeAsset: 16,
                  borderColor: blue,
                  borderRadius: 12,
                  onPressed: () async {
                    await handleGenerate();
                  }),
            ),
          ],
        ),
      ),
      body: BlocBuilder<AllImgCateBloc, AllImgCateState>(
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
                        child: NativeNormalAds(),
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
                    return ClickWidget(
                      function: () {
                        setState(() {
                          _imgSwapIndex = index;
                        });
                        context
                            .read<CurrentImgSwapCubit>()
                            .setImageSwap(state.images[index]);
                      },
                      child: Stack(
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                border: _imgSwapIndex == index
                                    ? Border.all(color: white, width: 2)
                                    : null,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: CachedImgFull(
                                  link: state.images[index].image)),
                          AigraphyWidget.countSwap(
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
                    style: style9(color: cultured)));
        }
      }),
    );
  }
}
