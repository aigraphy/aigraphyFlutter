import 'dart:convert';

import 'package:equatable/equatable.dart';

List<ImageRemoveBG> albumFromJson(String str) => List<ImageRemoveBG>.from(
    json.decode(str).map((dynamic x) => ImageRemoveBG.fromJson(x)));

String albumToJson(List<ImageRemoveBG> data) =>
    json.encode(List<dynamic>.from(data.map<dynamic>((x) => x.toJson())));

class ImageRemoveBG extends Equatable {
  const ImageRemoveBG({
    this.id,
    required this.imageRembg,
    required this.requestId,
  });
  factory ImageRemoveBG.fromJson(Map<String, dynamic> json) {
    return ImageRemoveBG(
        id: json['id'],
        imageRembg: json['image_rembg'],
        requestId: json['request_id']);
  }

  final int? id;
  final int requestId;
  final String imageRembg;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'request_id': requestId,
        'image_rembg': imageRembg,
      };

  @override
  List<Object> get props => [id!, requestId, imageRembg];
}
