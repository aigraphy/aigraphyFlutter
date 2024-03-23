part of 'photo_bloc.dart';

sealed class PhotosEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class PhotosFetched extends PhotosEvent {
  PhotosFetched({required this.assetPathEntity});
  final AssetPathEntity assetPathEntity;
  @override
  List<Object> get props => [assetPathEntity];
}

final class ResetPhotos extends PhotosEvent {}
