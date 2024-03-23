import 'package:equatable/equatable.dart';

class ImgCateModel extends Equatable {
  const ImgCateModel(
      {this.id,
      required this.image,
      required this.categoryId,
      required this.isPro,
      required this.countSwap});
  factory ImgCateModel.convertToObj(Map<String, dynamic> json) {
    return ImgCateModel(
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

  @override
  List<Object> get props => [id!, image, categoryId, isPro, countSwap];
}
