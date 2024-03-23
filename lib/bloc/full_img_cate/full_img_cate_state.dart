part of 'full_img_cate_bloc.dart';

enum FullImageCategoryStatus { initial, success, failure }

final class FullImgCateState extends Equatable {
  const FullImgCateState({
    this.status = FullImageCategoryStatus.initial,
    this.images = const <ImgCateModel>[],
    this.hasReachedMax = false,
  });

  final FullImageCategoryStatus status;
  final List<ImgCateModel> images;
  final bool hasReachedMax;

  FullImgCateState copyWith({
    FullImageCategoryStatus? status,
    List<ImgCateModel>? images,
    bool? hasReachedMax,
  }) {
    return FullImgCateState(
      status: status ?? this.status,
      images: images ?? this.images,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''FullImageCategoryState { status: $status, hasReachedMax: $hasReachedMax, images: ${images.length} }''';
  }

  @override
  List<Object> get props => [status, images, hasReachedMax];
}
