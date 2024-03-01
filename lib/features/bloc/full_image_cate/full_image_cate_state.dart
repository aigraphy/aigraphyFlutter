part of 'full_image_cate_bloc.dart';

enum FullImageCategoryStatus { initial, success, failure }

final class FullImageCategoryState extends Equatable {
  const FullImageCategoryState({
    this.status = FullImageCategoryStatus.initial,
    this.images = const <ImageCategoryModel>[],
    this.hasReachedMax = false,
  });

  final FullImageCategoryStatus status;
  final List<ImageCategoryModel> images;
  final bool hasReachedMax;

  FullImageCategoryState copyWith({
    FullImageCategoryStatus? status,
    List<ImageCategoryModel>? images,
    bool? hasReachedMax,
  }) {
    return FullImageCategoryState(
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
