import 'package:flutter_final/src/model/topic.dart';

class Folder{
  String createdBy;
  DateTime createdOn;
  String description;
  String folderName;
  Topic? topic;

  Folder({
    required this.createdBy,
    required this.createdOn,
    required this.description,
    required this.folderName,
    this.topic,
  });

  Map<String, dynamic> toMap() {
    return {
      'createdBy': createdBy,
      'createdOn': createdOn,
      'description': description,
      'folderName': folderName,
      'topic': topic?.toMap(),
    };
  }
}