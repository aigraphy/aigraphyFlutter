part of 'histories_bloc.dart';

sealed class HistoriesEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class HistoriesFetched extends HistoriesEvent {
  HistoriesFetched({required this.context});
  final BuildContext context;
  @override
  List<Object> get props => [context];
}

final class InsertHistory extends HistoriesEvent {
  InsertHistory({required this.historyModel});
  final HistoryModel historyModel;
  @override
  List<Object> get props => [historyModel];
}

final class UpdateRemImg extends HistoriesEvent {
  UpdateRemImg({required this.imageRemoveBG});
  final ImgRemoveBG imageRemoveBG;
  @override
  List<Object> get props => [imageRemoveBG];
}

class RemoveHistory extends HistoriesEvent {
  RemoveHistory({required this.id});
  final int id;
  @override
  List<Object> get props => [id];
}

class RemoveImgBG extends HistoriesEvent {
  RemoveImgBG({required this.requestId, required this.context});
  final int requestId;
  final BuildContext context;
  @override
  List<Object> get props => [requestId, context];
}

final class ResetHistories extends HistoriesEvent {}
