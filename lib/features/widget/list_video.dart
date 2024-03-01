import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../app/widget_support.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/styles.dart';
import '../../common/widget/animation_click.dart';
import '../../translations/export_lang.dart';
import '../bloc/list_photo/list_photo_bloc.dart';

const ThumbnailOption option = ThumbnailOption(
    size: ThumbnailSize.square(200), format: ThumbnailFormat.png);

class ListVideo extends StatefulWidget {
  const ListVideo({Key? key}) : super(key: key);

  @override
  State<ListVideo> createState() => _ListVideoState();
}

class _ListVideoState extends State<ListVideo> {
  late AssetPathEntity assetPathEntity;
  bool showVideos = false;
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
          type: RequestType.video, hasAll: true, onlyAll: false);
      if (listAll.isNotEmpty) {
        assetPathEntity = listAll[0];
        context
            .read<ListPhotosBloc>()
            .add(ListPhotosFetched(assetPathEntity: assetPathEntity));
        setState(() {
          showVideos = true;
        });
        return true;
      }
    }
    return false;
  }

  Widget itemView(AssetEntity photo) {
    return AnimationClick(
      function: () async {
        final File? file = await photo.file;
        final videoSelected = file!.readAsBytesSync();
        if (videoSelected.lengthInBytes / (1024 * 1024) > 20) {
          BotToast.showText(
              text: LocaleKeys.capacityVideoMaximum.tr(),
              textStyle: body(color: grey1100));
          return;
        }
        final Map<String, dynamic> res = {'path': file.path};
        Navigator.of(context).pop(res);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: AssetEntityImage(
                photo,
                isOriginal: false,
                thumbnailSize: option.size,
                thumbnailFormat: option.format,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
                bottom: 4,
                right: 4,
                child: Text(
                  '${formatDuration(photo.videoDuration)}',
                  style: caption1(color: grey1100, fontWeight: '600'),
                ))
          ],
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
    return showVideos
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    LocaleKeys.allVideos.tr(),
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
                                child: Text(LocaleKeys.noVideosFound.tr(),
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
                            itemCount:
                                state.hasReachedMax ? length : length + 1,
                            itemBuilder: (context, ind) {
                              final int index = ind < 1 ? ind : (ind - 1);
                              return index >= length
                                  ? const Center(
                                      child: CupertinoActivityIndicator())
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
                          input: LocaleKeys.selectMoreVideos.tr(),
                          borderRadius: 12,
                          vertical: 16,
                          onPressed: () async {
                            context
                                .read<ListPhotosBloc>()
                                .add(ResetListPhotos());
                            await PhotoManager.presentLimited();
                            final List<AssetPathEntity> listAll =
                                await PhotoManager.getAssetPathList(
                                    type: RequestType.video,
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
            child: Text(LocaleKeys.noVideosFound.tr(),
                style: subhead(color: grey800)));
  }
}
