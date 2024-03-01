import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'image_category_model.dart';

List<CategoryModel> albumFromJson(String str) => List<CategoryModel>.from(
    json.decode(str).map((dynamic x) => CategoryModel.fromJson(x)));

String albumToJson(List<CategoryModel> data) =>
    json.encode(List<dynamic>.from(data.map<dynamic>((x) => x.toJson())));

class CategoryModel extends Equatable {
  const CategoryModel(
      {this.id,
      required this.name,
      required this.number,
      required this.images});
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final List<ImageCategoryModel> images = [];
    if (json['ImageCategories'] != null) {
      for (final image in json['ImageCategories']) {
        images.add(ImageCategoryModel.fromJson(image));
      }
    }
    return CategoryModel(
        id: json['id'],
        name: json['name'],
        number: json['number'],
        images: images);
  }

  final int? id;
  final String name;
  final int number;
  final List<ImageCategoryModel> images;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'number': number,
        'images': images
      };

  @override
  List<Object> get props => [id!, name, number, images];
}
