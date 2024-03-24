part of 'all_img_cate_bloc.dart';

sealed class AllImgCateEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class AllImgCateFetched extends AllImgCateEvent {
  AllImgCateFetched({required this.categoryId});
  final int categoryId;
  @override
  List<Object> get props => [categoryId];
}

final class ResetAllImgCate extends AllImgCateEvent {}
