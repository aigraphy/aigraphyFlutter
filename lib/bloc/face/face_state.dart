import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../config_model/face_model.dart';

@immutable
abstract class FaceState extends Equatable {
  const FaceState();
}

class FaceLoading extends FaceState {
  @override
  List<Object> get props => [];
}

class FaceLoaded extends FaceState {
  const FaceLoaded({required this.recentFaces});

  final List<FaceModel> recentFaces;

  @override
  List<Object> get props => [recentFaces];
}

class FaceError extends FaceState {
  @override
  List<Object> get props => [];
}
