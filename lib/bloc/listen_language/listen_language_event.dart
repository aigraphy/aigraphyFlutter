import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class ListenLanguageEvent extends Equatable {
  const ListenLanguageEvent();
}

class InitialLanguage extends ListenLanguageEvent {
  const InitialLanguage({required this.context, required this.locale});
  final String locale;
  final BuildContext context;
  @override
  List<Object> get props => [context, locale];
}

class ChangeLanguage extends ListenLanguageEvent {
  const ChangeLanguage({required this.context, required this.locale});
  final String locale;
  final BuildContext context;
  @override
  List<Object> get props => [context, locale];
}
