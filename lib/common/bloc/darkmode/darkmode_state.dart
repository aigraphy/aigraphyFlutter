import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class DarkModeState extends Equatable {
  const DarkModeState();
  @override
  List<Object> get props => [];
}

class DarkModeInitial extends DarkModeState {}

class DarkModeLoading extends DarkModeState {}

class DarkModeSuccess extends DarkModeState {
  const DarkModeSuccess({required this.darkMode, required this.themeMode});
  final bool darkMode;
  final ThemeMode themeMode;
  @override
  List<Object> get props => [darkMode, themeMode];
}

class DarkModeFailure extends DarkModeState {
  const DarkModeFailure({required this.error});
  final String error;
  @override
  List<Object> get props => [error];
}
