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
import '../../../common/models/category_model.dart';

part 'list_categories_event.dart';
part 'list_categories_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class ListCategoriesBloc
    extends Bloc<ListCategoriesEvent, ListCategoriesState> {
  ListCategoriesBloc() : super(const ListCategoriesState()) {
    on<ListCategoriesFetched>(
      _onListCategoriesFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ResetListCategories>(
      _onResetListCategories,
    );
  }

  final User _firebaseUser = FirebaseAuth.instance.currentUser!;

  Future<void> _onListCategoriesFetched(
    ListCategoriesFetched event,
    Emitter<ListCategoriesState> emit,
  ) async {
    if (state.hasReachedMax) {
      return;
    }
    try {
      if (state.status == ListCategoriesStatus.initial) {
        final categories = await _fetchGenerates(CATEGORY_LIMIT);
        return emit(
          state.copyWith(
            status: ListCategoriesStatus.success,
            categories: categories,
            hasReachedMax: categories.length < CATEGORY_LIMIT,
          ),
        );
      }
      final categories =
          await _fetchGenerates(CATEGORY_LIMIT, state.categories.length);
      if (categories.isEmpty) {
        emit(state.copyWith(hasReachedMax: true));
      } else {
        emit(
          state.copyWith(
            status: ListCategoriesStatus.success,
            categories: List.of(state.categories)..addAll(categories),
            hasReachedMax: categories.length < CATEGORY_LIMIT,
          ),
        );
      }
    } catch (_) {
      emit(state.copyWith(status: ListCategoriesStatus.failure));
    }
  }

  Future<void> _onResetListCategories(
    ResetListCategories event,
    Emitter<ListCategoriesState> emit,
  ) async {
    return emit(const ListCategoriesState());
  }

  Future<List<CategoryModel>> _fetchGenerates(int limit, [int page = 0]) async {
    final List<CategoryModel> categories = [];
    final String? token = await _firebaseUser.getIdToken();
    await Config.initializeClient(token!)
        .value
        .query(QueryOptions(
            document: gql(Queries.getCategories),
            variables: <String, dynamic>{'offset': page, 'limit': limit}))
        .then((value) async {
      if (!value.hasException && value.data!['Category'].length > 0) {
        for (dynamic res in value.data!['Category']) {
          final CategoryModel generate = CategoryModel.fromJson(res);
          categories.add(generate);
        }
      }
    });
    return categories;
  }
}
