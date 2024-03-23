part of 'categories_bloc.dart';

enum CategoriesStatus { initial, success, failure }

final class CategoriesState extends Equatable {
  const CategoriesState({
    this.status = CategoriesStatus.initial,
    this.categories = const <CateModel>[],
    this.hasReachedMax = false,
  });

  final CategoriesStatus status;
  final List<CateModel> categories;
  final bool hasReachedMax;

  CategoriesState copyWith({
    CategoriesStatus? status,
    List<CateModel>? categories,
    bool? hasReachedMax,
  }) {
    return CategoriesState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''ListCategoriesState { status: $status, hasReachedMax: $hasReachedMax, categories: ${categories.length} }''';
  }

  @override
  List<Object> get props => [status, categories, hasReachedMax];
}
