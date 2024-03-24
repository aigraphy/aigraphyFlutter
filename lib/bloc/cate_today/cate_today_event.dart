part of 'cate_today_bloc.dart';

sealed class CateTodayEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class CateTodayFetched extends CateTodayEvent {}

final class ResetCateToday extends CateTodayEvent {}
