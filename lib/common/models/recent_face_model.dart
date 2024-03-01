import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../constant/helper.dart';

List<RecentFaceModel> albumFromJson(String str) => List<RecentFaceModel>.from(
    json.decode(str).map((dynamic x) => RecentFaceModel.fromJson(x)));

String albumToJson(List<RecentFaceModel> data) =>
    json.encode(List<dynamic>.from(data.map<dynamic>((x) => x.toJson())));

class RecentFaceModel extends Equatable {
  const RecentFaceModel({
    this.id,
    required this.face,
    required this.uuid,
    required this.updatedAt,
  });
  factory RecentFaceModel.fromJson(Map<String, dynamic> json) {
    return RecentFaceModel(
      id: json['id'],
      face: json['face'],
      uuid: json['user_uuid'],
      updatedAt: DateTime.tryParse(json['updated_at']) ?? now,
    );
  }

  final int? id;
  final String uuid;
  final String face;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_uuid': uuid,
      'face': face,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object> get props => [id!, uuid, face, updatedAt];
}
