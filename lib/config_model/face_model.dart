import 'package:equatable/equatable.dart';

import '../config/config_helper.dart';

class FaceModel extends Equatable {
  const FaceModel({
    this.id,
    required this.face,
    required this.uuid,
    required this.updatedAt,
  });
  factory FaceModel.convertToObj(Map<String, dynamic> json) {
    return FaceModel(
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

  @override
  List<Object> get props => [id!, uuid, face, updatedAt];
}
