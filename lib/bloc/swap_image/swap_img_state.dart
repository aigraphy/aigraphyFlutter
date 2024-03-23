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
  const SwapImgLoaded({this.imageRes, this.url, this.requestId});
  final Uint8List? imageRes;
  final String? url;
  final int? requestId;

  @override
  List<Object?> get props => [url!, imageRes!, requestId!];
}

class SwapImgError extends SwapImgState {
  const SwapImgError({required this.error});
  final String error;
  @override
  List<Object> get props => [error];
}
