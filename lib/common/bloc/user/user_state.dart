import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../common/models/user_model.dart';

@immutable
abstract class UserState extends Equatable {
  const UserState();
}

class UserLoading extends UserState {
  @override
  List<Object> get props => [];
}

class UserLoaded extends UserState {
  const UserLoaded({required this.user});

  final UserModel user;

  @override
  List<Object> get props => [user];
}

class UserError extends UserState {
  @override
  List<Object> get props => [];
}
