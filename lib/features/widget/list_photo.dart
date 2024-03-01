import 'dart:io';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_editor_plus/options.dart' as o;
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../app/widget_support.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/widget/animation_click.dart';
import '../../translations/export_lang.dart';
import '../bloc/list_photo/list_photo_bloc.dart';
import '../screen/crop_image.dart';

const ThumbnailOption option = ThumbnailOption(
    size: ThumbnailSize.square(200), format: ThumbnailFormat.png);

class ListPhoto extends StatefulWidget {
  const ListPhoto({Key? key, required this.cropImage}) : super(key: key);
  final bool cropImage;

  @override
  State<ListPhoto> createState() => _ListPhotoState();
}

class _ListPhotoState extends State<ListPhoto> {
  late AssetPathEntity assetPathEntity;
  XFile? imageFile;
  late Uint8List imageSelected;
  bool showImages = false;
  bool selected = false;

  final _scrollController = ScrollController();

  void _onScroll() {
    if (_isBottom) {
      context
          .read<ListPhotosBloc>()
          .add(ListPhotosFetched(assetPathEntity: assetPathEntity));
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

  Future<bool> getPhotoRecent() async {
    final PermissionState result = await PhotoManager.requestPermissionExtend();
    if (result.hasAccess) {
      if (result == PermissionState.limited) {
        selected = true;
      }
      final List<AssetPathEntity> listAll = await PhotoManager.getAssetPathList(
          type: RequestType.image, hasAll: true, onlyAll: false);
      if (listAll.isNotEmpty) {
        assetPathEntity = listAll[0];
        context
            .read<ListPhotosBloc>()
            .add(ListPhotosFetched(assetPathEntity: assetPathEntity));
        setState(() {
          showImages = true;
        });
        return true;
      }
    }
    return false;
  }

  Future<void> takeAPhoto() async {
    imageFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 80);
    if (imageFile != null) {
      final File file = File(imageFile!.path);
      imageSelected = file.readAsBytesSync();
      if (imageSelected.lengthInBytes / (1024 * 1024) >= 2) {
        BotToast.showText(
            text: LocaleKeys.pleaseChoosePhoto.tr(),
            textStyle: body(color: grey1100));
        Navigator.of(context).pop();
      } else {
        if (widget.cropImage) {
          await cropImage();
        }
        final Map<String, dynamic> res = {
          'bytes': imageSelected,
          'path': file.path
        };
        Navigator.of(context).pop(res);
      }
    }
  }

  Future<void> cropImage() async {
    final Uint8List? croppedImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageCropperFreeStyle(
          image: imageSelected,
          availableRatios: const [
            o.AspectRatio(title: 'FREEDOM'),
          ],
        ),
      ),
    );
    if (croppedImage != null) {
      setState(() {
        imageSelected = croppedImage;
      });
    }
  }

  Widget itemView(AssetEntity photo) {
    return AnimationClick(
      function: () async {
        final File? file = await photo.file;
        imageSelected = file!.readAsBytesSync();
        if (imageSelected.lengthInBytes / (1024 * 1024) >= 2) {
          BotToast.showText(
              text: LocaleKeys.pleaseChoosePhoto.tr(),
              textStyle: body(color: grey1100));
          return;
        }
        if (file.path.contains('.gif')) {
          BotToast.showText(text: LocaleKeys.weDontSupportGif.tr());
        } else if (file.path.contains('.webp')) {
          BotToast.showText(text: LocaleKeys.weDontSupportWebp.tr());
        } else {
          if (widget.cropImage) {
            await cropImage();
          }
          final Map<String, dynamic> res = {
            'bytes': imageSelected,
            'path': file.path
          };
          Navigator.of(context).pop(res);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AssetEntityImage(
          photo,
          isOriginal: false,
          thumbnailSize: option.size,
          thumbnailFormat: option.format,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getPhotoRecent();
    context.read<ListPhotosBloc>().add(ResetListPhotos());
    _scrollController.addListener(_onScroll);
    selected = false;
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
  }

  @override
  Widget build(BuildContext context) {
    return showImages
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    LocaleKeys.allPhotos.tr(),
                    style: title4(color: grey1100),
                  )),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => Future.sync(
                    () {
                      context.read<ListPhotosBloc>().add(ResetListPhotos());
                      context.read<ListPhotosBloc>().add(
                          ListPhotosFetched(assetPathEntity: assetPathEntity));
                    },
                  ),
                  child: BlocBuilder<ListPhotosBloc, ListPhotosState>(
                    builder: (context, state) {
                      switch (state.status) {
                        case ListPhotosStatus.failure:
                          return Center(
                              child: Text(LocaleKeys.failedToFetchPhotos.tr(),
                                  style: subhead(color: grey800)));
                        case ListPhotosStatus.success:
                          if (state.photos.isEmpty) {
                            return Center(
                                child: Text(LocaleKeys.noPhotos.tr(),
                                    style: subhead(color: grey800)));
                          }
                          final length = state.photos.length;
                          return GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: 1,
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8),
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 16),
                            shrinkWrap: true,
                            controller: _scrollController,
                            itemCount: widget.cropImage
                                ? state.hasReachedMax
                                    ? length
                                    : length + 1
                                : state.photos.isNotEmpty
                                    ? state.hasReachedMax
                                        ? length + 1
                                        : length + 2
                                    : 1,
                            itemBuilder: (context, ind) {
                              final int index = widget.cropImage
                                  ? ind
                                  : ind < 1
                                      ? ind
                                      : (ind - 1);
                              return index >= length
                                  ? const Center(
                                      child: CupertinoActivityIndicator())
                                  : !widget.cropImage && ind == 0
                                      ? AnimationClick(
                                          function: takeAPhoto,
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                                color: grey400,
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: Image.asset(icCamera),
                                          ),
                                        )
                                      : itemView(state.photos[index]);
                            },
                          );
                        case ListPhotosStatus.initial:
                          return const Center(
                              child: CupertinoActivityIndicator());
                      }
                    },
                  ),
                ),
              ),
              selected
                  ? Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 32),
                      child: AppWidget.typeButtonStartAction(
                          context: context,
                          input: LocaleKeys.selectMoreImages.tr(),
                          borderRadius: 12,
                          vertical: 16,
                          onPressed: () async {
                            context
                                .read<ListPhotosBloc>()
                                .add(ResetListPhotos());
                            await PhotoManager.presentLimited();
                            final List<AssetPathEntity> listAll =
                                await PhotoManager.getAssetPathList(
                                    type: RequestType.image,
                                    hasAll: true,
                                    onlyAll: false);
                            if (listAll.isNotEmpty) {
                              assetPathEntity = listAll[0];
                              context.read<ListPhotosBloc>().add(
                                  ListPhotosFetched(
                                      assetPathEntity: assetPathEntity));
                              return true;
                            }
                          },
                          bgColor: primary,
                          borderColor: primary,
                          textColor: grey1100),
                    )
                  : const SizedBox()
            ],
          )
        : Center(
            child:
                Text(LocaleKeys.noPhotos.tr(), style: subhead(color: grey800)));
  }
}
