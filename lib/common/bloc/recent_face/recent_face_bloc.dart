import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import '../../graphql/config.dart';
import '../../graphql/mutations.dart';
import '../../graphql/queries.dart';
import '../../models/recent_face_model.dart';
import '../../util/upload_image.dart';
import '../user/bloc_user.dart';
import 'bloc_recent_face.dart';

class RecentFaceBloc extends Bloc<RecentFaceEvent, RecentFaceState> {
  RecentFaceBloc() : super(RecentFaceLoading()) {
    on<GetRecentFace>(_onGetRecentFace);
    on<UpdateFace>(_onUpdateFace);
    on<DeleteFace>(_onDeleteFace);
  }
  User firebaseUser = FirebaseAuth.instance.currentUser!;

  List<RecentFaceModel> recentFaces = [];

  Future<void> _onGetRecentFace(
      GetRecentFace event, Emitter<RecentFaceState> emit) async {
    // emit(RecentFaceLoading());
    try {
      recentFaces.clear();
      recentFaces = await getRecentFace();
      emit(RecentFaceLoaded(recentFaces: recentFaces));
    } catch (_) {
      emit(RecentFaceError());
    }
  }

  Future<void> _onUpdateFace(
      UpdateFace event, Emitter<RecentFaceState> emit) async {
    final state = this.state;
    if (state is RecentFaceLoaded) {
      try {
        if (recentFaces.length >=
            event.context.read<UserBloc>().userModel!.slotRecentFace) {
          recentFaces.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
          final recent = recentFaces.first;
          deleteFile(recent.face);
          updateRecentFace(recent.id!, event.face);
        } else {
          insertRecentFace(event.face);
        }

        emit(RecentFaceLoaded(recentFaces: recentFaces));
      } catch (_) {
        emit(RecentFaceError());
      }
    }
  }

  Future<void> _onDeleteFace(
      DeleteFace event, Emitter<RecentFaceState> emit) async {
    final state = this.state;
    if (state is RecentFaceLoaded) {
      emit(RecentFaceLoading());
      try {
        recentFaces.removeWhere((e) => e.id == event.id);
        deleteRecentFace(event.id);
        deleteFile(event.urlFace);
        emit(RecentFaceLoaded(recentFaces: recentFaces));
      } catch (_) {
        emit(RecentFaceError());
      }
    }
  }

  Future<List<RecentFaceModel>> getRecentFace() async {
    final List<RecentFaceModel> recents = [];
    final String? token = await firebaseUser.getIdToken();
    await Config.initializeClient(token!)
        .value
        .query(QueryOptions(
            document: gql(Queries.getRecentFace),
            variables: <String, dynamic>{
              'user_uuid': firebaseUser.uid,
            }))
        .then((value) {
      if (!value.hasException && value.data!['RecentFace'].length > 0) {
        for (dynamic r in value.data!['RecentFace']) {
          recents.add(RecentFaceModel.fromJson(r));
        }
      }
    });
    return recents;
  }

  Future<void> updateRecentFace(int id, String face) async {
    final String? token = await firebaseUser.getIdToken();
    await Config.initializeClient(token!).value.mutate(MutationOptions(
            document: gql(Mutations.updateRecentFace()),
            variables: <String, dynamic>{
              'id': id,
              'face': face,
            }));
  }

  Future<void> deleteRecentFace(int id) async {
    final String? token = await firebaseUser.getIdToken();
    await Config.initializeClient(token!).value.mutate(MutationOptions(
            document: gql(Mutations.deleteRecentFace()),
            variables: <String, dynamic>{
              'id': id,
            }));
  }

  Future<void> insertRecentFace(String face) async {
    final String? token = await firebaseUser.getIdToken();
    await Config.initializeClient(token!).value.mutate(MutationOptions(
            document: gql(Mutations.insertRecentFace()),
            variables: <String, dynamic>{
              'user_uuid': firebaseUser.uid,
              'face': face,
            }));
  }
}
