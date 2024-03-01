import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
sealed class RecentFaceEvent extends Equatable {
  const RecentFaceEvent();
}

class GetRecentFace extends RecentFaceEvent {
  @override
  List<Object> get props => [];
}

class UpdateFace extends RecentFaceEvent {
  const UpdateFace(this.face, this.context);
  final BuildContext context;
  final String face;
  @override
  List<Object> get props => [face, context];
}

class DeleteFace extends RecentFaceEvent {
  const DeleteFace(this.id, this.urlFace);
  final int id;
  final String urlFace;
  @override
  List<Object> get props => [id, urlFace];
}
