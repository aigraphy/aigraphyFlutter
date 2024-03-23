import 'package:equatable/equatable.dart';

class ImgRemoveBG extends Equatable {
  const ImgRemoveBG({
    this.id,
    required this.imageRembg,
    required this.requestId,
  });
  factory ImgRemoveBG.convertToObj(Map<String, dynamic> json) {
    return ImgRemoveBG(
        id: json['id'],
        imageRembg: json['image_rembg'],
        requestId: json['request_id']);
  }

  final int? id;
  final int requestId;
  final String imageRembg;

  @override
  List<Object> get props => [id!, requestId, imageRembg];
}
