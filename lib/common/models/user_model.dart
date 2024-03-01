import 'dart:convert';

import 'package:equatable/equatable.dart';

List<UserModel> albumFromJson(String str) => List<UserModel>.from(
    json.decode(str).map((dynamic x) => UserModel.fromJson(x)));

String albumToJson(List<UserModel> data) =>
    json.encode(List<dynamic>.from(data.map<dynamic>((x) => x.toJson())));

class UserModel extends Equatable {
  const UserModel(
      {this.id,
      required this.name,
      required this.email,
      required this.uuid,
      required this.token,
      required this.avatar,
      this.dateCheckIn,
      required this.language,
      required this.slotRecentFace,
      required this.slotHistory});
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        uuid: json['uuid'],
        token: json['token'],
        slotRecentFace: json['slot_recent_face'],
        slotHistory: json['slot_history'],
        avatar: json['avatar'],
        language: json['language'],
        dateCheckIn: json['date_checkin'] != null
            ? DateTime.tryParse(json['date_checkin'])
            : null);
  }

  final int? id;
  final String uuid;
  final String name;
  final String email;
  final String avatar;
  final int token;
  final DateTime? dateCheckIn;
  final String language;
  final int slotRecentFace;
  final int slotHistory;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'email': email,
        'uuid': uuid,
        'token': token,
        'avatar': avatar,
        'date_checkin': dateCheckIn,
        'slot_recent_face': slotRecentFace,
        'slot_history': slotHistory,
        'language': language
      };

  @override
  List<Object> get props => [
        uuid,
        name,
        email,
        avatar,
        token,
        language,
        dateCheckIn!,
        slotRecentFace,
        slotHistory
      ];
}
