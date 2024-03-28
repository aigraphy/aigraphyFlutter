import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../config/config_helper.dart';
import '../../config_graphql/config_mutation.dart';
import '../../config_graphql/config_query.dart';
import '../../config_graphql/graphql.dart';
import '../../config_model/post_model.dart';

part 'list_posts_event.dart';
part 'list_posts_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class ListPostsBloc extends Bloc<ListPostsEvent, ListPostsState> {
  ListPostsBloc() : super(const ListPostsState()) {
    on<ListPostsFetched>(
      _onListPostsFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<InsertPost>(
      _onInsertPost,
      transformer: throttleDroppable(throttleDuration),
    );
    on<DeletePost>(
      _onDeletePost,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ResetListPosts>(
      _onResetListPosts,
      transformer: throttleDroppable(throttleDuration),
    );
    on<LikePost>(
      _onLikePost,
      transformer: throttleDroppable(throttleDuration),
    );
    on<UnLikePost>(
      _onUnLikePost,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final User _firebaseUser = FirebaseAuth.instance.currentUser!;

  Future<void> _onListPostsFetched(
    ListPostsFetched event,
    Emitter<ListPostsState> emit,
  ) async {
    if (state.hasReachedMax) {
      return;
    }
    try {
      if (state.status == ListPostsStatus.initial) {
        final posts = await _fetchPosts();
        return emit(
          state.copyWith(
            status: ListPostsStatus.success,
            posts: posts,
            hasReachedMax: posts.length < POST_LIMIT,
          ),
        );
      }
      final posts = await _fetchPosts(state.posts.length);
      if (posts.isEmpty) {
        emit(state.copyWith(hasReachedMax: true));
      } else {
        emit(
          state.copyWith(
            status: ListPostsStatus.success,
            posts: List.of(state.posts)..addAll(posts),
            hasReachedMax: posts.length < POST_LIMIT,
          ),
        );
      }
    } catch (_) {
      emit(state.copyWith(status: ListPostsStatus.failure));
    }
  }

  Future<void> _onResetListPosts(
    ResetListPosts event,
    Emitter<ListPostsState> emit,
  ) async {
    return emit(const ListPostsState());
  }

  Future<void> _onLikePost(
    LikePost event,
    Emitter<ListPostsState> emit,
  ) async {
    try {
      state.posts[event.index].likes += 1;
      return emit(
        state.copyWith(
          posts: state.posts,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: ListPostsStatus.failure));
    }
  }

  Future<void> _onUnLikePost(
    UnLikePost event,
    Emitter<ListPostsState> emit,
  ) async {
    try {
      state.posts[event.index].likes -= 1;
      return emit(
        state.copyWith(
          posts: state.posts,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: ListPostsStatus.failure));
    }
  }

  Future<void> _onInsertPost(
    InsertPost event,
    Emitter<ListPostsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ListPostsStatus.initial));
      state.posts.insert(0, event.post);

      return emit(
        state.copyWith(posts: state.posts, status: ListPostsStatus.success),
      );
    } catch (_) {
      emit(state.copyWith(status: ListPostsStatus.failure));
    }
  }

  Future<void> _onDeletePost(
    DeletePost event,
    Emitter<ListPostsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ListPostsStatus.initial));
      state.posts.removeWhere((e) => e.id == event.id);
      deletePost(event.id);
      return emit(
        state.copyWith(posts: state.posts, status: ListPostsStatus.success),
      );
    } catch (_) {
      emit(state.copyWith(status: ListPostsStatus.failure));
    }
  }

  Future<List<PostModel>> _fetchPosts([int page = 0]) async {
    final List<PostModel> posts = [];
    final String? token = await _firebaseUser.getIdToken();
    await Graphql.initialize(token!)
        .value
        .query(QueryOptions(
            document: gql(ConfigQuery.getPosts),
            variables: <String, dynamic>{'offset': page}))
        .then((value) async {
      if (!value.hasException && value.data!['Post'].length > 0) {
        for (dynamic res in value.data!['Post']) {
          final PostModel post = PostModel.convertToObj(res);
          posts.add(post);
        }
      }
    });
    return posts;
  }

  Future<void> deletePost(int postId) async {
    final String? token = await _firebaseUser.getIdToken();
    Graphql.initialize(token!).value.mutate(MutationOptions(
            document: gql(ConfigMutation.deletePost()),
            variables: <String, dynamic>{
              'id': postId,
            }));
  }
}
