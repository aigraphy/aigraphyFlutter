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
      required this.isPro,
      required this.countSwap});
  factory ImageCategoryModel.fromJson(Map<String, dynamic> json) {
    return ImageCategoryModel(
        id: json['id'],
        image: json['image'],
        categoryId: json['category_id'],
        isPro: json['is_pro'],
        countSwap: json['count_swap']);
  }

  final int? id;
  final String image;
  final int categoryId;
  final int countSwap;
  final bool isPro;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'image': image,
        'category_id': categoryId,
        'is_pro': isPro,
        'count_swap': countSwap,
      };

  @override
  List<Object> get props => [id!, image, categoryId, isPro, countSwap];
}
