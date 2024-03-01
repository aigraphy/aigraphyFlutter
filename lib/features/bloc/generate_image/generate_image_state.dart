import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
sealed class GenerateImageState extends Equatable {
  const GenerateImageState();
}

class GenerateImageLoading extends GenerateImageState {
  @override
  List<Object> get props => [];
}

class GenerateImageLoaded extends GenerateImageState {
  const GenerateImageLoaded({this.imageRes, this.url, this.requestId});
  final Uint8List? imageRes;
  final String? url;
  final int? requestId;

  @override
  List<Object?> get props => [url!, imageRes!, requestId!];
}

class GenerateImageError extends GenerateImageState {
  const GenerateImageError({required this.error});
  final String error;
  @override
  List<Object> get props => [error];
}
