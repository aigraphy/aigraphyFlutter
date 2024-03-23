import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';

import '../../config_graphql/config_mutation.dart';
import '../../config_graphql/config_query.dart';
import '../../config_graphql/graphql.dart';
import '../../config_model/face_model.dart';
import '../../util/upload_file_DO.dart';
import '../person/bloc_person.dart';
import 'bloc_face.dart';

class FaceBloc extends Bloc<FaceEvent, FaceState> {
  FaceBloc() : super(FaceLoading()) {
    on<GetFace>(_onGetFaces);
    on<UpdateFace>(_onUpdateFace);
    on<DeleteFace>(_onDeleteFace);
  }
  User userFB = FirebaseAuth.instance.currentUser!;

  List<FaceModel> faces = [];

  Future<void> _onGetFaces(GetFace event, Emitter<FaceState> emit) async {
    try {
      faces.clear();
      faces = await getFaces();
      emit(FaceLoaded(faces: faces));
    } catch (_) {
      emit(FaceError());
    }
  }

  Future<void> _onUpdateFace(UpdateFace event, Emitter<FaceState> emit) async {
    final state = this.state;
    if (state is FaceLoaded) {
      try {
        if (faces.length >=
            event.context.read<PersonBloc>().userModel!.slotFaces) {
          faces.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
          final recent = faces.first;
          deleteFileDO(recent.face);
          updateFace(recent.id!, event.face);
        } else {
          insertFace(event.face);
        }

        emit(FaceLoaded(faces: faces));
      } catch (_) {
        emit(FaceError());
      }
    }
  }

  Future<void> _onDeleteFace(DeleteFace event, Emitter<FaceState> emit) async {
    final state = this.state;
    if (state is FaceLoaded) {
      emit(FaceLoading());
      try {
        faces.removeWhere((e) => e.id == event.id);
        deleteFace(event.id);
        deleteFileDO(event.urlFace);
        emit(FaceLoaded(faces: faces));
      } catch (_) {
        emit(FaceError());
      }
    }
  }

  Future<List<FaceModel>> getFaces() async {
    final List<FaceModel> recents = [];
    final String? token = await userFB.getIdToken();
    await Graphql.initialize(token!)
        .value
        .query(QueryOptions(
            document: gql(ConfigQuery.getFace),
            variables: <String, dynamic>{
              'user_uuid': userFB.uid,
            }))
        .then((value) {
      if (!value.hasException && value.data!['RecentFace'].length > 0) {
        for (dynamic r in value.data!['RecentFace']) {
          recents.add(FaceModel.convertToObj(r));
        }
      }
    });
    return recents;
  }

  Future<void> updateFace(int id, String face) async {
    final String? token = await userFB.getIdToken();
    await Graphql.initialize(token!).value.mutate(MutationOptions(
            document: gql(ConfigMutation.updateFace()),
            variables: <String, dynamic>{
              'id': id,
              'face': face,
            }));
  }

  Future<void> deleteFace(int id) async {
    final String? token = await userFB.getIdToken();
    await Graphql.initialize(token!).value.mutate(MutationOptions(
            document: gql(ConfigMutation.deleteFace()),
            variables: <String, dynamic>{
              'id': id,
            }));
  }

  Future<void> insertFace(String face) async {
    final String? token = await userFB.getIdToken();
    await Graphql.initialize(token!).value.mutate(MutationOptions(
            document: gql(ConfigMutation.insertFace()),
            variables: <String, dynamic>{
              'user_uuid': userFB.uid,
              'face': face,
            }));
  }
}
