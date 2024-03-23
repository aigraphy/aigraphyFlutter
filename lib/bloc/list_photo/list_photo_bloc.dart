import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stream_transform/stream_transform.dart';

part 'list_photo_event.dart';
part 'list_photo_state.dart';

const throttleDuration = Duration(milliseconds: 100);
const int _sizePerPageAll = 40;

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class ListPhotosBloc extends Bloc<ListPhotosEvent, ListPhotosState> {
  ListPhotosBloc() : super(const ListPhotosState()) {
    on<ListPhotosFetched>(
      _onListPhotosFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ResetListPhotos>(
      _onResetListPhotos,
    );
  }

  late AssetPathEntity assetPathEntity;

  Future<void> _onListPhotosFetched(
    ListPhotosFetched event,
    Emitter<ListPhotosState> emit,
  ) async {
    if (state.hasReachedMax) {
      return;
    }
    try {
      if (state.status == ListPhotosStatus.initial) {
        final photos = await _getPhotos(event.assetPathEntity);
        return emit(
          state.copyWith(
            status: ListPhotosStatus.success,
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
            status: ListPhotosStatus.success,
            photos: List.of(state.photos)..addAll(photos),
            hasReachedMax: photos.length < _sizePerPageAll,
          ),
        );
      }
    } catch (_) {
      emit(state.copyWith(status: ListPhotosStatus.failure));
    }
  }

  Future<void> _onResetListPhotos(
    ResetListPhotos event,
    Emitter<ListPhotosState> emit,
  ) async {
    return emit(const ListPhotosState());
  }

  Future<List<AssetEntity>> _getPhotos(AssetPathEntity assetPathEntity,
      [int page = 0]) async {
    List<AssetEntity> photos = [];
    photos = await assetPathEntity.getAssetListPaged(
        page: page, size: _sizePerPageAll);
    return photos;
  }
}
