part of 'histories_bloc.dart';

enum HistoriesStatus { initial, success, failure }

final class HistoriesState extends Equatable {
  const HistoriesState({
    this.status = HistoriesStatus.initial,
    this.requests = const <HistoryModel>[],
    this.hasReachedMax = false,
  });

  final HistoriesStatus status;
  final List<HistoryModel> requests;
  final bool hasReachedMax;

  HistoriesState copyWith({
    HistoriesStatus? status,
    List<HistoryModel>? requests,
    bool? hasReachedMax,
  }) {
    return HistoriesState(
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
