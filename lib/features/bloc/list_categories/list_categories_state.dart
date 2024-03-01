part of 'list_categories_bloc.dart';

enum ListCategoriesStatus { initial, success, failure }

final class ListCategoriesState extends Equatable {
  const ListCategoriesState({
    this.status = ListCategoriesStatus.initial,
    this.categories = const <CategoryModel>[],
    this.hasReachedMax = false,
  });

  final ListCategoriesStatus status;
  final List<CategoryModel> categories;
  final bool hasReachedMax;

  ListCategoriesState copyWith({
    ListCategoriesStatus? status,
    List<CategoryModel>? categories,
    bool? hasReachedMax,
  }) {
    return ListCategoriesState(
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
