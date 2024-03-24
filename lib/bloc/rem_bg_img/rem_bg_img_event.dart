import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
sealed class RemBGImgEvent extends Equatable {
  const RemBGImgEvent();
}

class InitialRemBGImg extends RemBGImgEvent {
  const InitialRemBGImg(
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

class ResetRemBGImg extends RemBGImgEvent {
  const ResetRemBGImg({this.hasLoaded = false});
  final bool hasLoaded;
  @override
  List<Object> get props => [hasLoaded];
}

class RemBGImg extends RemBGImgEvent {
  const RemBGImg();
  @override
  List<Object> get props => [];
}
