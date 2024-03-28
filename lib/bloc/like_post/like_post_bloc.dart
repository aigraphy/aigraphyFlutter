import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import '../../config_graphql/config_mutation.dart';
import '../../config_graphql/graphql.dart';
import 'bloc_like_post.dart';

class LikePostBloc extends Bloc<LikePostEvent, LikePostState> {
  LikePostBloc() : super(LikePostLoading()) {
    on<GetLikePost>(_onGetLikePost);
    on<InsertLikePost>(_onInsertLikePost);
    on<DeleteLikePost>(_onDeleteLikePost);
  }
  List<int> likedPostIds = [];
  final User _firebaseUser = FirebaseAuth.instance.currentUser!;

  Future<void> _onGetLikePost(
      GetLikePost event, Emitter<LikePostState> emit) async {
    emit(LikePostLoading());
    try {
      likedPostIds.clear();
      likedPostIds = event.likedPosts.map((e) => e.postId).toList();
      emit(LikePostLoaded(likedPostIds: likedPostIds));
    } catch (_) {
      emit(LikePostError());
    }
  }

  Future<void> _onInsertLikePost(
      InsertLikePost event, Emitter<LikePostState> emit) async {
    final state = this.state;
    if (state is LikePostLoaded) {
      emit(LikePostLoading());
      try {
        likedPostIds.add(event.postId);
        insertLikePost(event.postId);
        emit(LikePostLoaded(likedPostIds: likedPostIds));
      } catch (_) {
        emit(LikePostError());
      }
    }
  }

  Future<void> _onDeleteLikePost(
      DeleteLikePost event, Emitter<LikePostState> emit) async {
    final state = this.state;
    if (state is LikePostLoaded) {
      emit(LikePostLoading());
      try {
        likedPostIds.remove(event.postId);
        deleteLikePost(event.postId);
        emit(LikePostLoaded(likedPostIds: likedPostIds));
      } catch (_) {
        emit(LikePostError());
      }
    }
  }

  Future<void> insertLikePost(int postId) async {
    final String? token = await _firebaseUser.getIdToken();
    Graphql.initialize(token!).value.mutate(MutationOptions(
            document: gql(ConfigMutation.insertLikePost()),
            variables: <String, dynamic>{
              'user_uuid': _firebaseUser.uid,
              'post_id': postId
            }));
  }

  Future<void> deleteLikePost(int postId) async {
    final String? token = await _firebaseUser.getIdToken();
    Graphql.initialize(token!).value.mutate(MutationOptions(
            document: gql(ConfigMutation.deleteLikePost()),
            variables: <String, dynamic>{
              'user_uuid': _firebaseUser.uid,
              'post_id': postId
            }));
  }
}
