part of 'list_photo_bloc.dart';

sealed class ListPhotosEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class ListPhotosFetched extends ListPhotosEvent {
  ListPhotosFetched({required this.assetPathEntity});
  final AssetPathEntity assetPathEntity;
  @override
  List<Object> get props => [assetPathEntity];
}

final class ResetListPhotos extends ListPhotosEvent {}
