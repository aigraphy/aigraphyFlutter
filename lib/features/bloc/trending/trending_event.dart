part of 'trending_bloc.dart';

sealed class TrendingEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class TrendingFetched extends TrendingEvent {}

final class TrendingCount extends TrendingEvent {
  TrendingCount({
    required this.categoryModel,
  });
  final ImageCategoryModel categoryModel;
  @override
  List<Object> get props => [categoryModel];
}

final class ResetTrending extends TrendingEvent {}
