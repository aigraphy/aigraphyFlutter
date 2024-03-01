import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../models/recent_face_model.dart';

@immutable
abstract class RecentFaceState extends Equatable {
  const RecentFaceState();
}

class RecentFaceLoading extends RecentFaceState {
  @override
  List<Object> get props => [];
}

class RecentFaceLoaded extends RecentFaceState {
  const RecentFaceLoaded({required this.recentFaces});

  final List<RecentFaceModel> recentFaces;

  @override
  List<Object> get props => [recentFaces];
}

class RecentFaceError extends RecentFaceState {
  @override
  List<Object> get props => [];
}
