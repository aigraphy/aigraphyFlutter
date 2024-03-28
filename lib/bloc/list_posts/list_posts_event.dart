part of 'list_posts_bloc.dart';

sealed class ListPostsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class ListPostsFetched extends ListPostsEvent {}

final class ResetListPosts extends ListPostsEvent {}

final class InsertPost extends ListPostsEvent {
  InsertPost({required this.post});
  final PostModel post;
  @override
  List<Object> get props => [post];
}

final class LikePost extends ListPostsEvent {
  LikePost({required this.index});
  final int index;
  @override
  List<Object> get props => [index];
}

final class UnLikePost extends ListPostsEvent {
  UnLikePost({required this.index});
  final int index;
  @override
  List<Object> get props => [index];
}

final class DeletePost extends ListPostsEvent {
  DeletePost({required this.id});
  final int id;
  @override
  List<Object> get props => [id];
}
