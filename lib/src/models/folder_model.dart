import 'package:flutter_final/src/models/topic_model.dart';

class Folder{
  String createdBy;
  DateTime createdOn;
  String description;
  String folderName;
  List<Topic> topic;

  Folder({
    required this.createdBy,
    required this.createdOn,
    required this.description,
    required this.folderName,
    required this.topic,
  });

  Map<String, dynamic> toMap() {
    return {
      'createdBy': createdBy,
      'createdOn': createdOn.toString(),
      'description': description,
      'folderName': folderName,
      'topic': topic,
    };
  }

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      createdBy: map['createdBy'],
      createdOn: DateTime.parse(map['createdOn']), 
      description: map['description'],
      folderName: map['folderName'],
      topic: List<Topic>.from(map['topics'].map((x) => Topic.fromMap(x))),
    );
  }
}