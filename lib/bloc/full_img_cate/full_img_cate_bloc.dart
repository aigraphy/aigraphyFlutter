import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../config/config_helper.dart';
import '../../config_graphql/config_query.dart';
import '../../config_graphql/graphql.dart';
import '../../config_model/img_cate_model.dart';

part 'full_img_cate_event.dart';
part 'full_img_cate_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class FullImgCateBloc extends Bloc<FullImgCateEvent, FullImgCateState> {
  FullImgCateBloc() : super(const FullImgCateState()) {
    on<FullImgCateFetched>(
      _onFullImageCategoryFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ResetFullImgCate>(
      _onResetFullImageCategory,
    );
  }

  final User userFB = FirebaseAuth.instance.currentUser!;

  Future<void> _onFullImageCategoryFetched(
    FullImgCateFetched event,
    Emitter<FullImgCateState> emit,
  ) async {
    if (state.hasReachedMax) {
      return;
    }
    try {
      if (state.status == FullImageCategoryStatus.initial) {
        final images =
            await _fetchImageCategory(event.categoryId, IMAGE_CATEGORY_LIMIT);
        return emit(
          state.copyWith(
            status: FullImageCategoryStatus.success,
            images: images,
            hasReachedMax: images.length < IMAGE_CATEGORY_LIMIT,
          ),
        );
      }
      final images = await _fetchImageCategory(
          event.categoryId, IMAGE_CATEGORY_LIMIT, state.images.length);
      if (images.isEmpty) {
        emit(state.copyWith(hasReachedMax: true));
      } else {
        emit(
          state.copyWith(
            status: FullImageCategoryStatus.success,
            images: List.of(state.images)..addAll(images),
            hasReachedMax: images.length < IMAGE_CATEGORY_LIMIT,
          ),
        );
      }
    } catch (_) {
      emit(state.copyWith(status: FullImageCategoryStatus.failure));
    }
  }

  Future<void> _onResetFullImageCategory(
    ResetFullImgCate event,
    Emitter<FullImgCateState> emit,
  ) async {
    return emit(const FullImgCateState());
  }

  Future<List<ImgCateModel>> _fetchImageCategory(int categoryId, int limit,
      [int page = 0]) async {
    final List<ImgCateModel> images = [];
    final String? token = await userFB.getIdToken();
    await Graphql.initialize(token!)
        .value
        .query(QueryOptions(
            document: gql(ConfigQuery.getFullImgCate),
            variables: <String, dynamic>{
              'category_id': categoryId,
              'offset': page,
              'limit': limit
            }))
        .then((value) async {
      if (!value.hasException && value.data!['ImageCategory'].length > 0) {
        for (dynamic res in value.data!['ImageCategory']) {
          final ImgCateModel image = ImgCateModel.convertToObj(res);
          images.add(image);
        }
      }
    });
    return images;
  }
}
