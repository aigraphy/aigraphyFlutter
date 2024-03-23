part of 'new_today_bloc.dart';

enum NewTodayStatus { initial, success, failure }

final class NewTodayState extends Equatable {
  const NewTodayState({
    this.status = NewTodayStatus.initial,
    this.images = const <ImgCateModel>[],
    this.hasReachedMax = false,
  });

  final NewTodayStatus status;
  final List<ImgCateModel> images;
  final bool hasReachedMax;

  NewTodayState copyWith({
    NewTodayStatus? status,
    List<ImgCateModel>? images,
    bool? hasReachedMax,
  }) {
    return NewTodayState(
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
