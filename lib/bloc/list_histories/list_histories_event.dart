part of 'list_histories_bloc.dart';

sealed class ListHistoriesEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class ListHistoriesFetched extends ListHistoriesEvent {
  ListHistoriesFetched({required this.context});
  final BuildContext context;
  @override
  List<Object> get props => [context];
}

final class InsertHistory extends ListHistoriesEvent {
  InsertHistory({required this.requestModel});
  final HistoryModel requestModel;
  @override
  List<Object> get props => [requestModel];
}

final class UpdateRemImg extends ListHistoriesEvent {
  UpdateRemImg({required this.imageRemoveBG});
  final ImgRemoveBG imageRemoveBG;
  @override
  List<Object> get props => [imageRemoveBG];
}

class RemoveHistory extends ListHistoriesEvent {
  RemoveHistory({required this.id});
  final int id;
  @override
  List<Object> get props => [id];
}

class RemoveImgBG extends ListHistoriesEvent {
  RemoveImgBG({required this.requestId, required this.context});
  final int requestId;
  final BuildContext context;
  @override
  List<Object> get props => [requestId, context];
}

final class ResetListHistories extends ListHistoriesEvent {}
