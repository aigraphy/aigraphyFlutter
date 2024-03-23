import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
sealed class FaceEvent extends Equatable {
  const FaceEvent();
}

class GetFace extends FaceEvent {
  @override
  List<Object> get props => [];
}

class UpdateFace extends FaceEvent {
  const UpdateFace(this.face, this.context);
  final BuildContext context;
  final String face;
  @override
  List<Object> get props => [face, context];
}

class DeleteFace extends FaceEvent {
  const DeleteFace(this.id, this.urlFace);
  final int id;
  final String urlFace;
  @override
  List<Object> get props => [id, urlFace];
}
