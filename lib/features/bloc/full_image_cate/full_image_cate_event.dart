part of 'full_image_cate_bloc.dart';

sealed class FullImageCategoryEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class FullImageCategoryFetched extends FullImageCategoryEvent {
  FullImageCategoryFetched({required this.categoryId});
  final int categoryId;
  @override
  List<Object> get props => [categoryId];
}

final class ResetFullImageCategory extends FullImageCategoryEvent {}
