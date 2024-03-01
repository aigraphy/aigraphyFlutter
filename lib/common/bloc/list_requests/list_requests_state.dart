part of 'list_requests_bloc.dart';

enum ListRequestsStatus { initial, success, failure }

final class ListRequestsState extends Equatable {
  const ListRequestsState({
    this.status = ListRequestsStatus.initial,
    this.requests = const <RequestModel>[],
    this.hasReachedMax = false,
  });

  final ListRequestsStatus status;
  final List<RequestModel> requests;
  final bool hasReachedMax;

  ListRequestsState copyWith({
    ListRequestsStatus? status,
    List<RequestModel>? requests,
    bool? hasReachedMax,
  }) {
    return ListRequestsState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''ListRequestsState { status: $status, hasReachedMax: $hasReachedMax, requests: ${requests.length} }''';
  }

  @override
  List<Object> get props => [status, requests, hasReachedMax];
}
