part of 'new_today_bloc.dart';

sealed class NewTodayEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class NewTodayFetched extends NewTodayEvent {}

final class ResetNewToday extends NewTodayEvent {}
