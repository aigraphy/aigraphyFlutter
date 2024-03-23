import 'package:equatable/equatable.dart';

class FbModel extends Equatable {
  const FbModel({this.id, required this.content, required this.userUuid});
  factory FbModel.convertToObj(Map<String, dynamic> json) {
    return FbModel(
      id: json['id'],
      content: json['content'],
      userUuid: json['user_uuid'],
    );
  }

  final int? id;
  final String content;
  final String userUuid;

  @override
  List<Object> get props => [content, userUuid];
}
