import 'package:equatable/equatable.dart';
import 'img_removebg.dart';

// ignore: must_be_immutable
class HistoryModel extends Equatable {
  HistoryModel(
      {this.id,
      required this.imageRes,
      required this.uuid,
      this.fromCate = false,
      this.imageRemoveBG});
  factory HistoryModel.convertToObj(Map<String, dynamic> json) {
    return HistoryModel(
        id: json['id'],
        imageRes: json['image_res'],
        uuid: json['uuid'],
        fromCate: json['from_cate'],
        imageRemoveBG: json['ImageRemBG'] != null
            ? ImgRemoveBG.convertToObj(json['ImageRemBG'])
            : null);
  }

  final int? id;
  final String uuid;
  final String imageRes;
  final bool fromCate;
  ImgRemoveBG? imageRemoveBG;

  @override
  List<Object> get props => [id!, uuid, imageRes, fromCate];
}
