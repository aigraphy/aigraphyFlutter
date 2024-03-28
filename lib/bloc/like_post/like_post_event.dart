import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../config_model/like_post_model.dart';

@immutable
sealed class LikePostEvent extends Equatable {
  const LikePostEvent();
}

class GetLikePost extends LikePostEvent {
  const GetLikePost({required this.likedPosts});
  final List<LikePostModel> likedPosts;
  @override
  List<Object> get props => [likedPosts];
}

class InsertLikePost extends LikePostEvent {
  const InsertLikePost({required this.postId});
  final int postId;
  @override
  List<Object> get props => [postId];
}

class DeleteLikePost extends LikePostEvent {
  const DeleteLikePost({required this.postId});
  final int postId;
  @override
  List<Object> get props => [postId];
}
