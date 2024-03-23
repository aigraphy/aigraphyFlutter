part of 'trending_bloc.dart';

enum TrendingStatus { initial, success, failure }

final class TrendingState extends Equatable {
  const TrendingState({
    this.status = TrendingStatus.initial,
    this.images = const <ImgCateModel>[],
    this.hasReachedMax = false,
  });

  final TrendingStatus status;
  final List<ImgCateModel> images;
  final bool hasReachedMax;

  TrendingState copyWith({
    TrendingStatus? status,
    List<ImgCateModel>? images,
    bool? hasReachedMax,
  }) {
    return TrendingState(
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
