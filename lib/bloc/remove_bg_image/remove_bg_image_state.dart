import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
sealed class RemoveBGImageState extends Equatable {
  const RemoveBGImageState();
}

class RemoveBGImageLoading extends RemoveBGImageState {
  @override
  List<Object> get props => [];
}

class RemoveBGImageLoaded extends RemoveBGImageState {
  const RemoveBGImageLoaded({this.imageRes, this.url});
  final Uint8List? imageRes;
  final String? url;

  @override
  List<Object?> get props => [url!, imageRes!];
}

class RemoveBGImageError extends RemoveBGImageState {
  const RemoveBGImageError({required this.error});
  final String error;
  @override
  List<Object> get props => [error];
}
