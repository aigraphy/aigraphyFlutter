import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
sealed class RemoveBGImageEvent extends Equatable {
  const RemoveBGImageEvent();
}

class InitialRemoveBGImage extends RemoveBGImageEvent {
  const InitialRemoveBGImage(
      {required this.context,
      required this.link,
      this.option,
      required this.requestId});
  final BuildContext context;
  final String link;
  final String? option;
  final int requestId;
  @override
  List<Object> get props => [context, link, requestId];
}

class ResetRemoveBGImage extends RemoveBGImageEvent {
  const ResetRemoveBGImage({this.hasLoaded = false});
  final bool hasLoaded;
  @override
  List<Object> get props => [hasLoaded];
}

class RemoveBGImage extends RemoveBGImageEvent {
  const RemoveBGImage();
  @override
  List<Object> get props => [];
}
