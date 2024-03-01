import 'dart:convert';

import 'package:equatable/equatable.dart';

List<FeedbackModel> albumFromJson(String str) => List<FeedbackModel>.from(
    json.decode(str).map((dynamic x) => FeedbackModel.fromJson(x)));

String albumToJson(List<FeedbackModel> data) =>
    json.encode(List<dynamic>.from(data.map<dynamic>((x) => x.toJson())));

class FeedbackModel extends Equatable {
  const FeedbackModel({this.id, required this.content, required this.userUuid});
  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'],
      content: json['content'],
      userUuid: json['user_uuid'],
    );
  }

  final int? id;
  final String content;
  final String userUuid;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'content': content,
        'user_uuid': userUuid,
      };

  @override
  List<Object> get props => [content, userUuid];
}
