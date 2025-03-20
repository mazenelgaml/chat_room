// To parse this JSON data, do
//
//     final registerModel = registerModelFromJson(jsonString);

import 'dart:convert';

RegisterModel registerModelFromJson(String str) => RegisterModel.fromJson(json.decode(str));

String registerModelToJson(RegisterModel data) => json.encode(data.toJson());

class RegisterModel {
  String? path;
  String? uri;
  int? timestamp;
  String? organization;
  String? application;
  List<Entity>? entities;
  String? action;
  List<dynamic>? data;
  int? duration;
  String? applicationName;

  RegisterModel({
    this.path,
    this.uri,
    this.timestamp,
    this.organization,
    this.application,
    this.entities,
    this.action,
    this.data,
    this.duration,
    this.applicationName,
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
    path: json["path"],
    uri: json["uri"],
    timestamp: json["timestamp"],
    organization: json["organization"],
    application: json["application"],
    entities: json["entities"] == null ? [] : List<Entity>.from(json["entities"]!.map((x) => Entity.fromJson(x))),
    action: json["action"],
    data: json["data"] == null ? [] : List<dynamic>.from(json["data"]!.map((x) => x)),
    duration: json["duration"],
    applicationName: json["applicationName"],
  );

  Map<String, dynamic> toJson() => {
    "path": path,
    "uri": uri,
    "timestamp": timestamp,
    "organization": organization,
    "application": application,
    "entities": entities == null ? [] : List<dynamic>.from(entities!.map((x) => x.toJson())),
    "action": action,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x)),
    "duration": duration,
    "applicationName": applicationName,
  };
}

class Entity {
  String? uuid;
  String? type;
  int? created;
  int? modified;
  String? username;
  bool? activated;

  Entity({
    this.uuid,
    this.type,
    this.created,
    this.modified,
    this.username,
    this.activated,
  });

  factory Entity.fromJson(Map<String, dynamic> json) => Entity(
    uuid: json["uuid"],
    type: json["type"],
    created: json["created"],
    modified: json["modified"],
    username: json["username"],
    activated: json["activated"],
  );

  Map<String, dynamic> toJson() => {
    "uuid": uuid,
    "type": type,
    "created": created,
    "modified": modified,
    "username": username,
    "activated": activated,
  };
}
