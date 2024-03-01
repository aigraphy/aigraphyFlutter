import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class DarkModeEvent extends Equatable {
  const DarkModeEvent();
}

class ChangeDarkMode extends DarkModeEvent {
  const ChangeDarkMode({required this.darkMode});
  final bool darkMode;
  @override
  List<Object> get props => [darkMode];
}
