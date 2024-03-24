part of 'cate_trending_bloc.dart';

sealed class CateTrendingEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class CateTrendingFetched extends CateTrendingEvent {}

final class CateTrendingCount extends CateTrendingEvent {
  CateTrendingCount({
    required this.categoryModel,
  });
  final ImgCateModel categoryModel;
  @override
  List<Object> get props => [categoryModel];
}

final class ResetCateTrending extends CateTrendingEvent {}
