part of 'list_histories_bloc.dart';

enum ListHistoriesStatus { initial, success, failure }

final class ListHistoriesState extends Equatable {
  const ListHistoriesState({
    this.status = ListHistoriesStatus.initial,
    this.requests = const <HistoryModel>[],
    this.hasReachedMax = false,
  });

  final ListHistoriesStatus status;
  final List<HistoryModel> requests;
  final bool hasReachedMax;

  ListHistoriesState copyWith({
    ListHistoriesStatus? status,
    List<HistoryModel>? requests,
    bool? hasReachedMax,
  }) {
    return ListHistoriesState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''ListHistoriesState { status: $status, hasReachedMax: $hasReachedMax, requests: ${requests.length} }''';
  }

  @override
  List<Object> get props => [status, requests, hasReachedMax];
}
