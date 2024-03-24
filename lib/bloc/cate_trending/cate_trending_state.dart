part of 'cate_trending_bloc.dart';

enum CateTrendingStatus { initial, success, failure }

final class CateTrendingState extends Equatable {
  const CateTrendingState({
    this.status = CateTrendingStatus.initial,
    this.images = const <ImgCateModel>[],
    this.hasReachedMax = false,
  });

  final CateTrendingStatus status;
  final List<ImgCateModel> images;
  final bool hasReachedMax;

  CateTrendingState copyWith({
    CateTrendingStatus? status,
    List<ImgCateModel>? images,
    bool? hasReachedMax,
  }) {
    return CateTrendingState(
      status: status ?? this.status,
      images: images ?? this.images,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''TrendingState { status: $status, hasReachedMax: $hasReachedMax, images: ${images.length} }''';
  }

  @override
  List<Object> get props => [status, images, hasReachedMax];
}
