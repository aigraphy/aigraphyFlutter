part of 'photo_bloc.dart';

enum PhotosStatus { initial, success, failure }

final class PhotosState extends Equatable {
  const PhotosState({
    this.status = PhotosStatus.initial,
    this.photos = const <AssetEntity>[],
    this.hasReachedMax = false,
  });

  final PhotosStatus status;
  final List<AssetEntity> photos;
  final bool hasReachedMax;

  PhotosState copyWith({
    PhotosStatus? status,
    List<AssetEntity>? photos,
    bool? hasReachedMax,
  }) {
    return PhotosState(
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
