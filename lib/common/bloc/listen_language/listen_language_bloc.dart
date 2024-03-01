import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../translations/export_lang.dart';
import 'bloc_listen_language.dart';

class ListenLanguageBloc
    extends Bloc<ListenLanguageEvent, ListenLanguageState> {
  ListenLanguageBloc() : super(ListenLanguageLoading()) {
    on<InitialLanguage>(_onInitialLanguage);
    on<ChangeLanguage>(_onChangeLanguage);
  }
  late String locale;
  late String language;

  String getLanguage(String locale) {
    switch (locale) {
      case 'es':
        return 'Spanish';
      case 'hi':
        return 'Hindi';
      case 'ja':
        return 'Japanese';
      case 'pt':
        return 'Portuguese';
      case 'vi':
        return 'Vietnamese';
      case 'it':
        return 'Italian';
      default:
        return 'English';
    }
  }

  Future<void> _onInitialLanguage(
      InitialLanguage event, Emitter<ListenLanguageState> emit) async {
    emit(ListenLanguageLoading());
    try {
      locale = event.locale;
      language = getLanguage(event.locale);
      event.context.setLocale(Locale(event.locale));
      final engine = WidgetsFlutterBinding.ensureInitialized();
      engine.performReassemble();
      emit(ListenLanguageSuccess(locale: event.locale));
    } catch (e) {
      emit(ListenLanguageFailure(error: e.toString()));
    }
  }

  Future<void> _onChangeLanguage(
      ChangeLanguage event, Emitter<ListenLanguageState> emit) async {
    emit(ListenLanguageLoading());
    try {
      locale = event.locale;
      language = getLanguage(event.locale);
      event.context.setLocale(Locale(event.locale));
      final engine = WidgetsFlutterBinding.ensureInitialized();
      engine.performReassemble();
      emit(ListenLanguageSuccess(locale: event.locale));
    } catch (e) {
      emit(ListenLanguageFailure(error: e.toString()));
    }
  }
}
