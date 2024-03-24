import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../config_graphql/config_mutation.dart';
import '../../config_graphql/config_query.dart';
import '../../config_graphql/graphql.dart';
import '../../config_model/img_cate_model.dart';

part 'cate_trending_event.dart';
part 'cate_trending_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class CateTrendingBloc extends Bloc<CateTrendingEvent, CateTrendingState> {
  CateTrendingBloc() : super(const CateTrendingState()) {
    on<CateTrendingFetched>(
      _onCateTrendingFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ResetCateTrending>(
      _onResetCateTrending,
    );
    on<CateTrendingCount>(
      _onCateTrendingCount,
    );
  }

  final User userFB = FirebaseAuth.instance.currentUser!;

  Future<void> _onCateTrendingFetched(
    CateTrendingFetched event,
    Emitter<CateTrendingState> emit,
  ) async {
    try {
      final images = await _fetchCateTrending();
      return emit(
        CateTrendingState(
          status: CateTrendingStatus.success,
          images: images,
          hasReachedMax: true,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: CateTrendingStatus.failure));
    }
  }

  Future<void> _onCateTrendingCount(
    CateTrendingCount event,
    Emitter<CateTrendingState> emit,
  ) async {
    try {
      _updateCountImage(
          event.categoryModel.id!, event.categoryModel.countSwap + 1);
      return emit(state.copyWith(status: CateTrendingStatus.success));
    } catch (_) {
      emit(state.copyWith(status: CateTrendingStatus.failure));
    }
  }

  Future<void> _onResetCateTrending(
    ResetCateTrending event,
    Emitter<CateTrendingState> emit,
  ) async {
    return emit(const CateTrendingState());
  }

  Future<List<ImgCateModel>> _fetchCateTrending() async {
    final List<ImgCateModel> images = [];
    final String? token = await userFB.getIdToken();
    await Graphql.initialize(token!)
        .value
        .query(QueryOptions(document: gql(ConfigQuery.getImgTrending)))
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

  Future<void> _updateCountImage(int id, int countSwap) async {
    final String? token = await userFB.getIdToken();
    await Graphql.initialize(token!).value.mutate(MutationOptions(
            document: gql(ConfigMutation.updateImgCate()),
            variables: {
              'id': id,
              'count_swap': countSwap,
            }));
  }
}
