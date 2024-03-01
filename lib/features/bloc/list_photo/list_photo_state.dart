part of 'list_photo_bloc.dart';

enum ListPhotosStatus { initial, success, failure }

final class ListPhotosState extends Equatable {
  const ListPhotosState({
    this.status = ListPhotosStatus.initial,
    this.photos = const <AssetEntity>[],
    this.hasReachedMax = false,
  });

  final ListPhotosStatus status;
  final List<AssetEntity> photos;
  final bool hasReachedMax;

  ListPhotosState copyWith({
    ListPhotosStatus? status,
    List<AssetEntity>? photos,
    bool? hasReachedMax,
  }) {
    return ListPhotosState(
      status: status ?? this.status,
      photos: photos ?? this.photos,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''ListPhotosState { status: $status, hasReachedMax: $hasReachedMax, photos: ${photos.length} }''';
  }

  @override
  List<Object> get props => [status, photos, hasReachedMax];
}
