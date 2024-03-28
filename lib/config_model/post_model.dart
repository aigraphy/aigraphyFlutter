import 'package:equatable/equatable.dart';

import '../config/config_helper.dart';
import 'person_model.dart';

// ignore: must_be_immutable
class PostModel extends Equatable {
  PostModel(
      {this.id,
      required this.userUuid,
      required this.historyId,
      required this.likes,
      required this.published,
      required this.linkImage,
      this.person});
  factory PostModel.convertToObj(Map<String, dynamic> json) {
    return PostModel(
        id: json['id'],
        userUuid: json['user_uuid'],
        historyId: json['history_id'],
        likes: json['LikePosts_aggregate']['aggregate']['count'] ?? 0,
        linkImage: json['link_image'],
        published: DateTime.tryParse(json['published']) ?? now,
        person: PersonModel.convertToObj(json['User']));
  }

  final int? id;
  final String userUuid;
  final int historyId;
  int likes;
  final DateTime published;
  final String linkImage;
  final PersonModel? person;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id!,
        'user_uuid': userUuid,
        'history_id': historyId,
        'published': published,
        'likes': likes,
        'link_image': linkImage,
      };

  @override
  List<Object> get props =>
      [id!, published, userUuid, historyId, likes, linkImage];
}
