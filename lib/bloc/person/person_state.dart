import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../config_model/person_model.dart';

@immutable
abstract class PersonState extends Equatable {
  const PersonState();
}

class UserLoading extends PersonState {
  @override
  List<Object> get props => [];
}

class UserLoaded extends PersonState {
  const UserLoaded({required this.user});

  final PersonModel user;

  @override
  List<Object> get props => [user];
}

class UserError extends PersonState {
  @override
  List<Object> get props => [];
}
