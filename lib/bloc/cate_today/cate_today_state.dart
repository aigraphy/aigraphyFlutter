part of 'cate_today_bloc.dart';

enum CateTodayStatus { initial, success, failure }

final class CateTodayState extends Equatable {
  const CateTodayState({
    this.status = CateTodayStatus.initial,
    this.images = const <ImgCateModel>[],
    this.hasReachedMax = false,
  });

  final CateTodayStatus status;
  final List<ImgCateModel> images;
  final bool hasReachedMax;

  CateTodayState copyWith({
    CateTodayStatus? status,
    List<ImgCateModel>? images,
    bool? hasReachedMax,
  }) {
    return CateTodayState(
      status: status ?? this.status,
      images: images ?? this.images,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''NewTodayState { status: $status, hasReachedMax: $hasReachedMax, images: ${images.length} }''';
  }

  @override
  List<Object> get props => [status, images, hasReachedMax];
}
