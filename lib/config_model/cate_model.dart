import 'package:equatable/equatable.dart';
import 'img_cate_model.dart';

class CateModel extends Equatable {
  const CateModel(
      {this.id,
      required this.name,
      required this.number,
      required this.isPro,
      required this.images});
  factory CateModel.convertToObj(Map<String, dynamic> json) {
    final List<ImgCateModel> images = [];
    if (json['ImageCategories'] != null) {
      for (final image in json['ImageCategories']) {
        images.add(ImgCateModel.convertToObj(image));
      }
    }
    return CateModel(
        id: json['id'],
        name: json['name'],
        number: json['number'],
        isPro: json['is_pro'],
        images: images);
  }

  final int? id;
  final String name;
  final int number;
  final bool isPro;
  final List<ImgCateModel> images;

  @override
  List<Object> get props => [id!, name, number, isPro, images];
}
