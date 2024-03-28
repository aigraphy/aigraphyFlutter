import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
sealed class SwapImgState extends Equatable {
  const SwapImgState();
}

class SwapImgLoading extends SwapImgState {
  @override
  List<Object> get props => [];
}

class SwapImgLoaded extends SwapImgState {
  const SwapImgLoaded({this.imageRes, this.url, this.requestId, this.fromCate});
  final Uint8List? imageRes;
  final String? url;
  final int? requestId;
  final bool? fromCate;

  @override
  List<Object?> get props => [url!, imageRes!, requestId!, fromCate!];
}

class SwapImgError extends SwapImgState {
  const SwapImgError({required this.error});
  final String error;
  @override
  List<Object> get props => [error];
}
