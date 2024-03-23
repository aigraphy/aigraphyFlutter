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
import '../../config_model/cate_model.dart';

part 'categories_event.dart';
part 'categories_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  CategoriesBloc() : super(const CategoriesState()) {
    on<CategoriesFetched>(
      _onCategoriesFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ResetCategories>(
      _onResetCategories,
    );
  }

  final User userFB = FirebaseAuth.instance.currentUser!;

  Future<void> _onCategoriesFetched(
    CategoriesFetched event,
    Emitter<CategoriesState> emit,
  ) async {
    if (state.hasReachedMax) {
      return;
    }
    try {
      if (state.status == CategoriesStatus.initial) {
        final categories = await _fetchCategories(CATEGORY_LIMIT);
        return emit(
          state.copyWith(
            status: CategoriesStatus.success,
            categories: categories,
            hasReachedMax: categories.length < CATEGORY_LIMIT,
          ),
        );
      }
      final categories =
          await _fetchCategories(CATEGORY_LIMIT, state.categories.length);
      if (categories.isEmpty) {
        emit(state.copyWith(hasReachedMax: true));
      } else {
        emit(
          state.copyWith(
            status: CategoriesStatus.success,
            categories: List.of(state.categories)..addAll(categories),
            hasReachedMax: categories.length < CATEGORY_LIMIT,
          ),
        );
      }
    } catch (_) {
      emit(state.copyWith(status: CategoriesStatus.failure));
    }
  }

  Future<void> _onResetCategories(
    ResetCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    return emit(const CategoriesState());
  }

  Future<List<CateModel>> _fetchCategories(int limit, [int page = 0]) async {
    final List<CateModel> categories = [];
    final String? token = await userFB.getIdToken();
    await Graphql.initialize(token!)
        .value
        .query(QueryOptions(
            document: gql(ConfigQuery.getCategories),
            variables: <String, dynamic>{'offset': page, 'limit': limit}))
        .then((value) async {
      if (!value.hasException && value.data!['Category'].length > 0) {
        for (dynamic res in value.data!['Category']) {
          final CateModel generate = CateModel.convertToObj(res);
          categories.add(generate);
        }
      }
    });
    return categories;
  }
}
