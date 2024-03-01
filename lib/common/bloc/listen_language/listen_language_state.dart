import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class ListenLanguageState extends Equatable {
  const ListenLanguageState();
  @override
  List<Object> get props => [];
}

class ListenLanguageInitial extends ListenLanguageState {}

class ListenLanguageLoading extends ListenLanguageState {}

class ListenLanguageSuccess extends ListenLanguageState {
  const ListenLanguageSuccess({required this.locale});
  final String locale;
  @override
  List<Object> get props => [locale];
}

class ListenLanguageFailure extends ListenLanguageState {
  const ListenLanguageFailure({required this.error});
  final String error;
  @override
  List<Object> get props => [error];
}
