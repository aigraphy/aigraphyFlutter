import 'dart:convert';

import 'package:equatable/equatable.dart';

List<ImageCategoryModel> albumFromJson(String str) =>
    List<ImageCategoryModel>.from(
        json.decode(str).map((dynamic x) => ImageCategoryModel.fromJson(x)));

String albumToJson(List<ImageCategoryModel> data) =>
    json.encode(List<dynamic>.from(data.map<dynamic>((x) => x.toJson())));

class ImageCategoryModel extends Equatable {
  const ImageCategoryModel(
      {this.id,
      required this.image,
      required this.categoryId,
      required this.countSwap});
  factory ImageCategoryModel.fromJson(Map<String, dynamic> json) {
    return ImageCategoryModel(
        id: json['id'],
        image: json['image'],
        categoryId: json['category_id'],
        countSwap: json['count_swap']);
  }

  final int? id;
  final String image;
  final int categoryId;
  final int countSwap;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'image': image,
        'category_id': categoryId,
        'count_swap': countSwap,
      };

  @override
  List<Object> get props => [id!, image, categoryId, countSwap];
}
