import 'dart:io';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_editor_plus/options.dart' as o;
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../../translations/export_lang.dart';
import '../aigraphy_widget.dart';
import '../bloc/photo/photo_bloc.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_image.dart';
import '../screen/cropper_img.dart';
import 'click_widget.dart';

const ThumbnailOption option = ThumbnailOption(
    size: ThumbnailSize.square(200), format: ThumbnailFormat.png);

class ChoosePhoto extends StatefulWidget {
  const ChoosePhoto({Key? key, this.cropImage = false, this.sizeLimit = 16})
      : super(key: key);
  final bool cropImage;
  final double sizeLimit;

  @override
  State<ChoosePhoto> createState() => _ChoosePhotoState();
}

class _ChoosePhotoState extends State<ChoosePhoto> {
  late AssetPathEntity assetPathEntity;
  XFile? imageFile;
  late Uint8List imageSelected;
  bool showImages = false;
  bool selected = false;
  bool goToSetting = false;

  final _scrollController = ScrollController();

  void _onScroll() {
    if (_isBottom) {
      context
          .read<PhotosBloc>()
          .add(PhotosFetched(assetPathEntity: assetPathEntity));
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

  Future<void> getPhotoRecent() async {
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
            .read<PhotosBloc>()
            .add(PhotosFetched(assetPathEntity: assetPathEntity));
        setState(() {
          showImages = true;
        });
      }
    } else {
      goToSetting = true;
      setState(() {});
    }
  }

  Future<void> takeAPhoto() async {
    imageFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 80);
    if (imageFile != null) {
      final File file = File(imageFile!.path);
      imageSelected = file.readAsBytesSync();
      if (imageSelected.lengthInBytes / (1024 * 1024) > widget.sizeLimit) {
        BotToast.showText(
            text: widget.sizeLimit == 4
                ? LocaleKeys.pleaseChoosePhoto2.tr()
                : LocaleKeys.pleaseChoosePhoto.tr(),
            textStyle: style7(color: white));
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
        builder: (context) => CropperImg(
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
    return ClickWidget(
      function: () async {
        final File? file = await photo.file;
        imageSelected = file!.readAsBytesSync();
        if (imageSelected.lengthInBytes / (1024 * 1024) >= widget.sizeLimit) {
          BotToast.showText(
              text: widget.sizeLimit == 4
                  ? LocaleKeys.pleaseChoosePhoto2.tr()
                  : LocaleKeys.pleaseChoosePhoto.tr(),
              textStyle: style7(color: white));
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
    context.read<PhotosBloc>().add(ResetPhotos());
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
                    style: style5(color: white),
                  )),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => Future.sync(
                    () {
                      context.read<PhotosBloc>().add(ResetPhotos());
                      context
                          .read<PhotosBloc>()
                          .add(PhotosFetched(assetPathEntity: assetPathEntity));
                    },
                  ),
                  child: BlocBuilder<PhotosBloc, PhotosState>(
                    builder: (context, state) {
                      switch (state.status) {
                        case PhotosStatus.failure:
                          return Center(
                              child: Text(LocaleKeys.failedToFetchPhotos.tr(),
                                  style: style9(color: cultured)));
                        case PhotosStatus.success:
                          if (state.photos.isEmpty) {
                            return Center(
                                child: Text(LocaleKeys.noPhotos.tr(),
                                    style: style9(color: cultured)));
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
                            itemCount: state.photos.isNotEmpty
                                ? state.hasReachedMax
                                    ? length + 1
                                    : length + 2
                                : 1,
                            itemBuilder: (context, ind) {
                              final int index = ind < 1 ? ind : (ind - 1);
                              return index >= length
                                  ? const Center(
                                      child: CupertinoActivityIndicator())
                                  : ind == 0
                                      ? ClickWidget(
                                          function: takeAPhoto,
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                                color: cadetBlueCrayola,
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: Image.asset(ic_take_photo,
                                                color: white),
                                          ),
                                        )
                                      : itemView(state.photos[index]);
                            },
                          );
                        case PhotosStatus.initial:
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
                      child: AigraphyWidget.buttonCustom(
                          context: context,
                          input: LocaleKeys.selectMoreImages.tr(),
                          borderRadius: 12,
                          vertical: 16,
                          onPressed: () async {
                            context.read<PhotosBloc>().add(ResetPhotos());
                            await PhotoManager.presentLimited();
                            final List<AssetPathEntity> listAll =
                                await PhotoManager.getAssetPathList(
                                    type: RequestType.image,
                                    hasAll: true,
                                    onlyAll: false);
                            if (listAll.isNotEmpty) {
                              assetPathEntity = listAll[0];
                              context.read<PhotosBloc>().add(PhotosFetched(
                                  assetPathEntity: assetPathEntity));
                              return true;
                            }
                          },
                          bgColor: blue,
                          borderColor: blue,
                          textColor: white),
                    )
                  : const SizedBox()
            ],
          )
        : Center(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(LocaleKeys.noPhotos.tr(), style: style9(color: cultured)),
              const SizedBox(height: 16),
              if (goToSetting)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AigraphyWidget.buttonCustom(
                      context: context,
                      input: 'Go to Setting',
                      textColor: white,
                      bgColor: blue,
                      borderColor: blue,
                      borderRadius: 32,
                      onPressed: () async {
                        await PhotoManager.openSetting();
                      }),
                )
            ],
          ));
  }
}
