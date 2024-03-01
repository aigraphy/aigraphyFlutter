part of 'list_requests_bloc.dart';

sealed class ListRequestsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class ListRequestsFetched extends ListRequestsEvent {
  ListRequestsFetched({required this.context});
  final BuildContext context;
  @override
  List<Object> get props => [context];
}

final class InsertRequest extends ListRequestsEvent {
  InsertRequest({required this.requestModel});
  final RequestModel requestModel;
  @override
  List<Object> get props => [requestModel];
}

final class UpdateRemoveImage extends ListRequestsEvent {
  UpdateRemoveImage({required this.imageRemoveBG});
  final ImageRemoveBG imageRemoveBG;
  @override
  List<Object> get props => [imageRemoveBG];
}

class RemoveRequest extends ListRequestsEvent {
  RemoveRequest({required this.id});
  final int id;
  @override
  List<Object> get props => [id];
}

class RemoveImageBG extends ListRequestsEvent {
  RemoveImageBG({required this.requestId, required this.context});
  final int requestId;
  final BuildContext context;
  @override
  List<Object> get props => [requestId, context];
}

final class ResetListRequests extends ListRequestsEvent {}
