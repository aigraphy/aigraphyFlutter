part of 'list_categories_bloc.dart';

sealed class ListCategoriesEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class ListCategoriesFetched extends ListCategoriesEvent {}

final class ResetListCategories extends ListCategoriesEvent {}
