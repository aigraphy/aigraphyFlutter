part of 'list_posts_bloc.dart';

enum ListPostsStatus { initial, success, failure }

final class ListPostsState extends Equatable {
  const ListPostsState({
    this.status = ListPostsStatus.initial,
    this.posts = const <PostModel>[],
    this.hasReachedMax = false,
  });

  final ListPostsStatus status;
  final List<PostModel> posts;
  final bool hasReachedMax;

  ListPostsState copyWith({
    ListPostsStatus? status,
    List<PostModel>? posts,
    bool? hasReachedMax,
  }) {
    return ListPostsState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''ListPostsState { status: $status, hasReachedMax: $hasReachedMax, posts: ${posts.length} }''';
  }

  @override
  List<Object> get props => [status, posts, hasReachedMax];
}
