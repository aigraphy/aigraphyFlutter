import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../common/constant/helper.dart';
import '../../../common/graphql/config.dart';
import '../../../common/graphql/queries.dart';
import '../../../common/models/image_category_model.dart';

part 'full_image_cate_event.dart';
part 'full_image_cate_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class FullImageCategoryBloc
    extends Bloc<FullImageCategoryEvent, FullImageCategoryState> {
  FullImageCategoryBloc() : super(const FullImageCategoryState()) {
    on<FullImageCategoryFetched>(
      _onFullImageCategoryFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ResetFullImageCategory>(
      _onResetFullImageCategory,
    );
  }

  final User _firebaseUser = FirebaseAuth.instance.currentUser!;

  Future<void> _onFullImageCategoryFetched(
    FullImageCategoryFetched event,
    Emitter<FullImageCategoryState> emit,
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
    ResetFullImageCategory event,
    Emitter<FullImageCategoryState> emit,
  ) async {
    return emit(const FullImageCategoryState());
  }

  Future<List<ImageCategoryModel>> _fetchImageCategory(
      int categoryId, int limit,
      [int page = 0]) async {
    final List<ImageCategoryModel> images = [];
    final String? token = await _firebaseUser.getIdToken();
    await Config.initializeClient(token!)
        .value
        .query(QueryOptions(
            document: gql(Queries.getFullImageCategory),
            variables: <String, dynamic>{
              'category_id': categoryId,
              'offset': page,
              'limit': limit
            }))
        .then((value) async {
      if (!value.hasException && value.data!['ImageCategory'].length > 0) {
        for (dynamic res in value.data!['ImageCategory']) {
          final ImageCategoryModel image = ImageCategoryModel.fromJson(res);
          images.add(image);
        }
      }
    });
    return images;
  }
}
