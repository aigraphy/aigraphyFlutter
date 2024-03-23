import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
sealed class SwapImgEvent extends Equatable {
  const SwapImgEvent();
}

class InitialSwapImg extends SwapImgEvent {
  const InitialSwapImg(
      {required this.context,
      required this.srcPath,
      required this.dstPath,
      this.handleCoin = true});
  final BuildContext context;
  final String srcPath;
  final String dstPath;
  final bool handleCoin;
  @override
  List<Object> get props => [context, srcPath, dstPath, handleCoin];
}

class EditSwapImg extends SwapImgEvent {
  const EditSwapImg(
      {required this.result, required this.url, required this.requestId});
  final Uint8List result;
  final String url;
  final int requestId;
  @override
  List<Object> get props => [result, url, requestId];
}
