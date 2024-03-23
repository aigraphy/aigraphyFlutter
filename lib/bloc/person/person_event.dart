import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../config_model/person_model.dart';

@immutable
sealed class PersonEvent extends Equatable {
  const PersonEvent();
}

class GetUser extends PersonEvent {
  const GetUser(this.userModel, this.context);
  final BuildContext context;
  final PersonModel userModel;

  @override
  List<Object> get props => [userModel, context];
}

class UpdateCoinUser extends PersonEvent {
  const UpdateCoinUser(this.coin);
  final int coin;

  @override
  List<Object> get props => [coin];
}

class UpdateCurrentCheckIn extends PersonEvent {
  @override
  List<Object> get props => [];
}

class UpdateSlotRecentFace extends PersonEvent {
  @override
  List<Object> get props => [];
}

class UpdateSlotHistory extends PersonEvent {
  @override
  List<Object> get props => [];
}

class UpdateLanguageUser extends PersonEvent {
  const UpdateLanguageUser(this.language);
  final String language;

  @override
  List<Object> get props => [language];
}
