import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc_darkmode.dart';

class DarkModeBloc extends Bloc<DarkModeEvent, DarkModeState> {
  DarkModeBloc() : super(DarkModeLoading()) {
    on<ChangeDarkMode>(_onChangeDarkMode);
  }
  late ThemeMode themeMode;

  Future<void> _onChangeDarkMode(
      ChangeDarkMode event, Emitter<DarkModeState> emit) async {
    emit(DarkModeLoading());
    try {
      if (event.darkMode) {
        themeMode = ThemeMode.dark;
      } else {
        themeMode = ThemeMode.light;
      }
      emit(DarkModeSuccess(darkMode: event.darkMode, themeMode: themeMode));
    } catch (e) {
      emit(DarkModeFailure(error: e.toString()));
    }
  }
}
