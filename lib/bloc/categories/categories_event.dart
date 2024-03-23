part of 'categories_bloc.dart';

sealed class CategoriesEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class CategoriesFetched extends CategoriesEvent {}

final class ResetCategories extends CategoriesEvent {}
