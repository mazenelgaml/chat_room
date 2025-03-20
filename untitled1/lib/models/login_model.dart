// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  String? path;
  String? uri;
  int? timestamp;
  List<Entity>? entities;
  int? count;
  String? action;
  int? duration;

  LoginModel({
    this.path,
    this.uri,
    this.timestamp,
    this.entities,
    this.count,
    this.action,
    this.duration,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    path: json["path"],
    uri: json["uri"],
    timestamp: json["timestamp"],
    entities: json["entities"] == null ? [] : List<Entity>.from(json["entities"]!.map((x) => Entity.fromJson(x))),
    count: json["count"],
    action: json["action"],
    duration: json["duration"],
  );

  Map<String, dynamic> toJson() => {
    "path": path,
    "uri": uri,
    "timestamp": timestamp,
    "entities": entities == null ? [] : List<dynamic>.from(entities!.map((x) => x.toJson())),
    "count": count,
    "action": action,
    "duration": duration,
  };
}

class Entity {
  int? created;
  int? modified;
  String? type;
  String? uuid;
  String? username;
  bool? activated;

  Entity({
    this.created,
    this.modified,
    this.type,
    this.uuid,
    this.username,
    this.activated,
  });

  factory Entity.fromJson(Map<String, dynamic> json) => Entity(
    created: json["created"],
    modified: json["modified"],
    type: json["type"],
    uuid: json["uuid"],
    username: json["username"],
    activated: json["activated"],
  );

  Map<String, dynamic> toJson() => {
    "created": created,
    "modified": modified,
    "type": type,
    "uuid": uuid,
    "username": username,
    "activated": activated,
  };
}
