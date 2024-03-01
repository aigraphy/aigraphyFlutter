import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../common/models/user_model.dart';

@immutable
sealed class UserEvent extends Equatable {
  const UserEvent();
}

class GetUser extends UserEvent {
  const GetUser(this.userModel, this.context);
  final BuildContext context;
  final UserModel userModel;

  @override
  List<Object> get props => [userModel, context];
}

class UpdateTokenUser extends UserEvent {
  const UpdateTokenUser(this.token);
  final int token;

  @override
  List<Object> get props => [token];
}

class UpdateCurrentCheckIn extends UserEvent {
  @override
  List<Object> get props => [];
}

class UpdateSlotRecentFace extends UserEvent {
  @override
  List<Object> get props => [];
}

class UpdateSlotHistory extends UserEvent {
  @override
  List<Object> get props => [];
}

class UpdateLanguageUser extends UserEvent {
  const UpdateLanguageUser(this.language);
  final String language;

  @override
  List<Object> get props => [language];
}
