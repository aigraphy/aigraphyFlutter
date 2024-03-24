import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../config_graphql/config_query.dart';
import '../../config_graphql/graphql.dart';
import '../../config_model/img_cate_model.dart';

part 'cate_today_event.dart';
part 'cate_today_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class CateTodayBloc extends Bloc<CateTodayEvent, CateTodayState> {
  CateTodayBloc() : super(const CateTodayState()) {
    on<CateTodayFetched>(
      _onCateTodayFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ResetCateToday>(
      _onResetCateToday,
    );
  }

  final User userFB = FirebaseAuth.instance.currentUser!;

  Future<void> _onCateTodayFetched(
    CateTodayFetched event,
    Emitter<CateTodayState> emit,
  ) async {
    try {
      final images = await _fetchCateToday();
      return emit(
        CateTodayState(
          status: CateTodayStatus.success,
          images: images,
          hasReachedMax: true,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: CateTodayStatus.failure));
    }
  }

  Future<void> _onResetCateToday(
    ResetCateToday event,
    Emitter<CateTodayState> emit,
  ) async {
    return emit(const CateTodayState());
  }

  Future<List<ImgCateModel>> _fetchCateToday() async {
    final List<ImgCateModel> images = [];
    final String? token = await userFB.getIdToken();
    await Graphql.initialize(token!)
        .value
        .query(QueryOptions(document: gql(ConfigQuery.getImgToday)))
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
