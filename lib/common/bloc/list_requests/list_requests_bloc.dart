import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:graphql/client.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../common/graphql/config.dart';
import '../../../common/graphql/queries.dart';
import '../../../features/bloc/remove_bg_image/bloc_remove_bg_image.dart';
import '../../constant/helper.dart';
import '../../graphql/mutations.dart';
import '../../models/image_removebg.dart';
import '../../models/request_model.dart';
import '../user/bloc_user.dart';

part 'list_requests_event.dart';
part 'list_requests_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class ListRequestsBloc extends Bloc<ListRequestsEvent, ListRequestsState> {
  ListRequestsBloc() : super(const ListRequestsState()) {
    on<ListRequestsFetched>(
      _onListRequestsFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<InsertRequest>(
      _onInsertRequest,
      transformer: throttleDroppable(throttleDuration),
    );
    on<UpdateRemoveImage>(
      _onUpdateRemoveImage,
      transformer: throttleDroppable(throttleDuration),
    );
    on<RemoveRequest>(
      _onRemoveRequest,
      transformer: throttleDroppable(throttleDuration),
    );
    on<RemoveImageBG>(
      _onRemoveImageBG,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ResetListRequests>(
      _onResetListRequests,
    );
  }

  final User _firebaseUser = FirebaseAuth.instance.currentUser!;

  Future<void> _onListRequestsFetched(
    ListRequestsFetched event,
    Emitter<ListRequestsState> emit,
  ) async {
    if (state.hasReachedMax) {
      return;
    }
    try {
      if (state.status == ListRequestsStatus.initial) {
        final requests = await getRequest(HISTORY_LIMIT);
        return emit(
          state.copyWith(
            status: ListRequestsStatus.success,
            requests: requests,
            hasReachedMax: requests.length < HISTORY_LIMIT,
          ),
        );
      }
      final user = event.context.read<UserBloc>().userModel;
      if (state.requests.length >= user!.slotHistory) {
        emit(state.copyWith(hasReachedMax: true));
      } else {
        final requests = await getRequest(HISTORY_LIMIT, state.requests.length);
        emit(
          state.copyWith(
            status: ListRequestsStatus.success,
            requests: List.of(state.requests)..addAll(requests),
            hasReachedMax: requests.length < HISTORY_LIMIT,
          ),
        );
      }
    } catch (_) {
      emit(state.copyWith(status: ListRequestsStatus.failure));
    }
  }

  Future<void> _onInsertRequest(
    InsertRequest event,
    Emitter<ListRequestsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ListRequestsStatus.initial));
      state.requests.insert(0, event.requestModel);
      emit(
        state.copyWith(
            status: ListRequestsStatus.success, requests: state.requests),
      );
    } catch (_) {
      emit(state.copyWith(status: ListRequestsStatus.failure));
    }
  }

  Future<void> _onUpdateRemoveImage(
    UpdateRemoveImage event,
    Emitter<ListRequestsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ListRequestsStatus.initial));
      state.requests
          .firstWhere((e) => e.id == event.imageRemoveBG.requestId)
          .imageRemoveBG = event.imageRemoveBG;
      emit(
        state.copyWith(
            status: ListRequestsStatus.success, requests: state.requests),
      );
    } catch (_) {
      emit(state.copyWith(status: ListRequestsStatus.failure));
    }
  }

  Future<void> _onRemoveRequest(
    RemoveRequest event,
    Emitter<ListRequestsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ListRequestsStatus.initial));
      removeRequest(event.id);
      state.requests.removeWhere((element) => element.id == event.id);
      emit(
        state.copyWith(
            status: ListRequestsStatus.success, requests: state.requests),
      );
    } catch (_) {
      emit(state.copyWith(status: ListRequestsStatus.failure));
    }
  }

  Future<void> _onRemoveImageBG(
    RemoveImageBG event,
    Emitter<ListRequestsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ListRequestsStatus.initial));
      final imageBG = state.requests
          .firstWhere((e) => e.id == event.requestId)
          .imageRemoveBG;

      removeImageBG(imageBG!.id!);
      state.requests.firstWhere((e) => e.id == event.requestId).imageRemoveBG =
          null;
      event.context.read<RemoveBGImageBloc>().add(const RemoveBGImage());
      emit(
        state.copyWith(
            status: ListRequestsStatus.success, requests: state.requests),
      );
    } catch (_) {
      emit(state.copyWith(status: ListRequestsStatus.failure));
    }
  }

  Future<void> _onResetListRequests(
    ResetListRequests event,
    Emitter<ListRequestsState> emit,
  ) async {
    return emit(const ListRequestsState());
  }

  Future<List<RequestModel>> getRequest(int limit, [int page = 0]) async {
    final List<RequestModel> requests = [];
    final String? token = await _firebaseUser.getIdToken();
    await Config.initializeClient(token!)
        .value
        .query(QueryOptions(
            document: gql(Queries.getRequests),
            variables: <String, dynamic>{
              'uuid': _firebaseUser.uid,
              'offset': page,
              'limit': limit
            }))
        .then((value) {
      if (!value.hasException && value.data!['Request'].length > 0) {
        for (dynamic r in value.data!['Request']) {
          requests.add(RequestModel.fromJson(r));
        }
      }
    });
    return requests;
  }

  Future<void> removeRequest(int id) async {
    final String? token = await _firebaseUser.getIdToken();
    EasyLoading.show();
    await Config.initializeClient(token!).value.mutate(MutationOptions(
            document: gql(Mutations.deleteRequest()),
            variables: <String, dynamic>{
              'id': id,
            }));
    EasyLoading.dismiss();
  }

  Future<void> removeImageBG(int id) async {
    final String? token = await _firebaseUser.getIdToken();
    EasyLoading.show();
    await Config.initializeClient(token!).value.mutate(MutationOptions(
            document: gql(Mutations.deleteImageBG()),
            variables: <String, dynamic>{
              'id': id,
            }));
    EasyLoading.dismiss();
  }
}
