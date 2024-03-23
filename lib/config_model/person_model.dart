import 'package:equatable/equatable.dart';

class PersonModel extends Equatable {
  const PersonModel(
      {this.id,
      required this.name,
      required this.email,
      required this.uuid,
      required this.coin,
      required this.avatar,
      this.dateCheckIn,
      required this.language,
      required this.slotRecentFace,
      required this.slotHistory});
  factory PersonModel.convertToObj(Map<String, dynamic> json) {
    return PersonModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        uuid: json['uuid'],
        coin: json['token'],
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
  final int coin;
  final DateTime? dateCheckIn;
  final String language;
  final int slotRecentFace;
  final int slotHistory;

  @override
  List<Object> get props => [
        uuid,
        name,
        email,
        avatar,
        coin,
        language,
        slotRecentFace,
        slotHistory
      ];
}
