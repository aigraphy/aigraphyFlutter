import 'package:equatable/equatable.dart';

class LikePostModel extends Equatable {
  const LikePostModel({
    this.id,
    required this.postId,
    required this.userUuid,
  });
  factory LikePostModel.fromJson(Map<String, dynamic> json) {
    return LikePostModel(
        id: json['id'], postId: json['post_id'], userUuid: json['user_uuid']);
  }

  final int? id;
  final int postId;
  final String userUuid;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'post_id': postId,
        'user_uuid': userUuid,
      };

  @override
  List<Object> get props => [id!, postId, userUuid];
}
