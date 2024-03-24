import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
sealed class RemBGImgState extends Equatable {
  const RemBGImgState();
}

class RemBGImgLoading extends RemBGImgState {
  @override
  List<Object> get props => [];
}

class RemoveBGImageLoaded extends RemBGImgState {
  const RemoveBGImageLoaded({this.imageRes, this.url});
  final Uint8List? imageRes;
  final String? url;

  @override
  List<Object?> get props => [url!, imageRes!];
}

class RemoveBGImageError extends RemBGImgState {
  const RemoveBGImageError({required this.error});
  final String error;
  @override
  List<Object> get props => [error];
}
