import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stream_transform/stream_transform.dart';

part 'photo_event.dart';
part 'photo_state.dart';

const throttleDuration = Duration(milliseconds: 100);
const int _sizePerPageAll = 40;

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class PhotosBloc extends Bloc<PhotosEvent, PhotosState> {
  PhotosBloc() : super(const PhotosState()) {
    on<PhotosFetched>(
      _onPhotosFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ResetPhotos>(
      _onResetPhotos,
    );
  }

  late AssetPathEntity assetPathEntity;

  Future<void> _onPhotosFetched(
    PhotosFetched event,
    Emitter<PhotosState> emit,
  ) async {
    if (state.hasReachedMax) {
      return;
    }
    try {
      if (state.status == PhotosStatus.initial) {
        final photos = await _getPhotos(event.assetPathEntity);
        return emit(
          state.copyWith(
            status: PhotosStatus.success,
            photos: photos,
            hasReachedMax: photos.length < _sizePerPageAll,
          ),
        );
      }

      final photos = await _getPhotos(event.assetPathEntity,
          (state.photos.length / _sizePerPageAll).ceil());
      if (photos.isEmpty) {
        emit(state.copyWith(hasReachedMax: true));
      } else {
        emit(
          state.copyWith(
            status: PhotosStatus.success,
            photos: List.of(state.photos)..addAll(photos),
            hasReachedMax: photos.length < _sizePerPageAll,
          ),
        );
      }
    } catch (_) {
      emit(state.copyWith(status: PhotosStatus.failure));
    }
  }

  Future<void> _onResetPhotos(
    ResetPhotos event,
    Emitter<PhotosState> emit,
  ) async {
    return emit(const PhotosState());
  }

  Future<List<AssetEntity>> _getPhotos(AssetPathEntity assetPathEntity,
      [int page = 0]) async {
    List<AssetEntity> photos = [];
    photos = await assetPathEntity.getAssetListPaged(
        page: page, size: _sizePerPageAll);
    return photos;
  }
}
