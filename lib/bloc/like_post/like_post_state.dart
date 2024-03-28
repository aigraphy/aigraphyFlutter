import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class LikePostState extends Equatable {
  const LikePostState();
}

class LikePostLoading extends LikePostState {
  @override
  List<Object> get props => [];
}

class LikePostLoaded extends LikePostState {
  const LikePostLoaded({required this.likedPostIds});

  final List<int> likedPostIds;

  @override
  List<Object> get props => [likedPostIds];
}

class LikePostError extends LikePostState {
  @override
  List<Object> get props => [];
}
