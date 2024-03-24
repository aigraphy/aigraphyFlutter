import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:graphql/client.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../config/config_helper.dart';
import '../../config_graphql/config_mutation.dart';
import '../../config_graphql/config_query.dart';
import '../../config_graphql/graphql.dart';
import '../../config_model/history_model.dart';
import '../../config_model/img_removebg.dart';
import '../person/bloc_person.dart';
import '../rem_bg_img/bloc_rem_bg_img.dart';

part 'histories_event.dart';
part 'histories_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class HistoriesBloc extends Bloc<HistoriesEvent, HistoriesState> {
  HistoriesBloc() : super(const HistoriesState()) {
    on<HistoriesFetched>(
      _onRequestsFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<InsertHistory>(
      _onInsertRequest,
      transformer: throttleDroppable(throttleDuration),
    );
    on<UpdateRemImg>(
      _onUpdateRemoveImage,
      transformer: throttleDroppable(throttleDuration),
    );
    on<RemoveHistory>(
      _onRemoveRequest,
      transformer: throttleDroppable(throttleDuration),
    );
    on<RemoveImgBG>(
      _onRemoveImageBG,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ResetHistories>(
      _onResetRequests,
    );
  }

  final User userFB = FirebaseAuth.instance.currentUser!;

  Future<void> _onRequestsFetched(
    HistoriesFetched event,
    Emitter<HistoriesState> emit,
  ) async {
    if (state.hasReachedMax) {
      return;
    }
    try {
      if (state.status == HistoriesStatus.initial) {
        final requests = await _fetchHistories(HISTORY_LIMIT);
        return emit(
          state.copyWith(
            status: HistoriesStatus.success,
            requests: requests,
            hasReachedMax: requests.length < HISTORY_LIMIT,
          ),
        );
      }
      final user = event.context.read<PersonBloc>().userModel;
      if (state.requests.length >= user!.slotHistory) {
        emit(state.copyWith(hasReachedMax: true));
      } else {
        final requests =
            await _fetchHistories(HISTORY_LIMIT, state.requests.length);
        emit(
          state.copyWith(
            status: HistoriesStatus.success,
            requests: List.of(state.requests)..addAll(requests),
            hasReachedMax: requests.length < HISTORY_LIMIT,
          ),
        );
      }
    } catch (_) {
      emit(state.copyWith(status: HistoriesStatus.failure));
    }
  }

  Future<void> _onInsertRequest(
    InsertHistory event,
    Emitter<HistoriesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: HistoriesStatus.initial));
      state.requests.insert(0, event.requestModel);
      emit(
        state.copyWith(
            status: HistoriesStatus.success, requests: state.requests),
      );
    } catch (_) {
      emit(state.copyWith(status: HistoriesStatus.failure));
    }
  }

  Future<void> _onUpdateRemoveImage(
    UpdateRemImg event,
    Emitter<HistoriesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: HistoriesStatus.initial));
      state.requests
          .firstWhere((e) => e.id == event.imageRemoveBG.requestId)
          .imageRemoveBG = event.imageRemoveBG;
      emit(
        state.copyWith(
            status: HistoriesStatus.success, requests: state.requests),
      );
    } catch (_) {
      emit(state.copyWith(status: HistoriesStatus.failure));
    }
  }

  Future<void> _onRemoveRequest(
    RemoveHistory event,
    Emitter<HistoriesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: HistoriesStatus.initial));
      removeRequest(event.id);
      state.requests.removeWhere((element) => element.id == event.id);
      emit(
        state.copyWith(
            status: HistoriesStatus.success, requests: state.requests),
      );
    } catch (_) {
      emit(state.copyWith(status: HistoriesStatus.failure));
    }
  }

  Future<void> _onRemoveImageBG(
    RemoveImgBG event,
    Emitter<HistoriesState> emit,
  ) async {
    try {
      emit(state.copyWith(status: HistoriesStatus.initial));
      final imageBG = state.requests
          .firstWhere((e) => e.id == event.requestId)
          .imageRemoveBG;

      removeImageBG(imageBG!.id!);
      state.requests.firstWhere((e) => e.id == event.requestId).imageRemoveBG =
          null;
      event.context.read<RemBGImgBloc>().add(const RemBGImg());
      emit(
        state.copyWith(
            status: HistoriesStatus.success, requests: state.requests),
      );
    } catch (_) {
      emit(state.copyWith(status: HistoriesStatus.failure));
    }
  }

  Future<void> _onResetRequests(
    ResetHistories event,
    Emitter<HistoriesState> emit,
  ) async {
    return emit(const HistoriesState());
  }

  Future<List<HistoryModel>> _fetchHistories(int limit, [int page = 0]) async {
    final List<HistoryModel> requests = [];
    final String? token = await userFB.getIdToken();
    await Graphql.initialize(token!)
        .value
        .query(QueryOptions(
            document: gql(ConfigQuery.getHistories),
            variables: <String, dynamic>{
              'uuid': userFB.uid,
              'offset': page,
              'limit': limit
            }))
        .then((value) {
      if (!value.hasException && value.data!['Request'].length > 0) {
        for (dynamic r in value.data!['Request']) {
          requests.add(HistoryModel.convertToObj(r));
        }
      }
    });
    return requests;
  }

  Future<void> removeRequest(int id) async {
    final String? token = await userFB.getIdToken();
    EasyLoading.show();
    await Graphql.initialize(token!).value.mutate(MutationOptions(
            document: gql(ConfigMutation.deleteHistory()),
            variables: <String, dynamic>{
              'id': id,
            }));
    EasyLoading.dismiss();
  }

  Future<void> removeImageBG(int id) async {
    final String? token = await userFB.getIdToken();
    EasyLoading.show();
    await Graphql.initialize(token!).value.mutate(MutationOptions(
            document: gql(ConfigMutation.deleteImgBG()),
            variables: <String, dynamic>{
              'id': id,
            }));
    EasyLoading.dismiss();
  }
}
