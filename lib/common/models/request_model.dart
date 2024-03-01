import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'image_removebg.dart';

List<RequestModel> albumFromJson(String str) => List<RequestModel>.from(
    json.decode(str).map((dynamic x) => RequestModel.fromJson(x)));

String albumToJson(List<RequestModel> data) =>
    json.encode(List<dynamic>.from(data.map<dynamic>((x) => x.toJson())));

// ignore: must_be_immutable
class RequestModel extends Equatable {
  RequestModel(
      {this.id,
      required this.imageRes,
      required this.uuid,
      this.imageRemoveBG});
  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
        id: json['id'],
        imageRes: json['image_res'],
        uuid: json['uuid'],
        imageRemoveBG: json['ImageRemBG'] != null
            ? ImageRemoveBG.fromJson(json['ImageRemBG'])
            : null);
  }

  final int? id;
  final String uuid;
  final String imageRes;
  ImageRemoveBG? imageRemoveBG;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': uuid,
        'image_res': imageRes,
      };

  @override
  List<Object> get props => [id!, uuid, imageRes];
}
