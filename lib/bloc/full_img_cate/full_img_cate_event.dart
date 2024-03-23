part of 'full_img_cate_bloc.dart';

sealed class FullImgCateEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class FullImgCateFetched extends FullImgCateEvent {
  FullImgCateFetched({required this.categoryId});
  final int categoryId;
  @override
  List<Object> get props => [categoryId];
}

final class ResetFullImgCate extends FullImgCateEvent {}
