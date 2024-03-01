import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:stream_transform/stream_transform.dart';
import '../../../common/graphql/config.dart';
import '../../../common/graphql/queries.dart';
import '../../../common/models/image_category_model.dart';

part 'new_today_event.dart';
part 'new_today_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class NewTodayBloc extends Bloc<NewTodayEvent, NewTodayState> {
  NewTodayBloc() : super(const NewTodayState()) {
    on<NewTodayFetched>(
      _onNewTodayFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ResetNewToday>(
      _onResetNewToday,
    );
  }

  final User _firebaseUser = FirebaseAuth.instance.currentUser!;

  Future<void> _onNewTodayFetched(
    NewTodayFetched event,
    Emitter<NewTodayState> emit,
  ) async {
    try {
      final images = await _fetchImageNewToday();
      return emit(
        NewTodayState(
          status: NewTodayStatus.success,
          images: images,
          hasReachedMax: true,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: NewTodayStatus.failure));
    }
  }

  Future<void> _onResetNewToday(
    ResetNewToday event,
    Emitter<NewTodayState> emit,
  ) async {
    return emit(const NewTodayState());
  }

  Future<List<ImageCategoryModel>> _fetchImageNewToday() async {
    final List<ImageCategoryModel> images = [];
    final String? token = await _firebaseUser.getIdToken();
    await Config.initializeClient(token!)
        .value
        .query(QueryOptions(document: gql(Queries.getImageToday)))
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
