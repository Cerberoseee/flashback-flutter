import 'package:flutter_final/src/models/topic_model.dart';

class Folder {
  String createdBy;
  DateTime createdOn;
  String description;
  String folderName;
  String descriptionQuery;
  String folderNameQuery;
  String status;
  List<Topic> topic;

  Folder({
    required this.createdBy,
    required this.createdOn,
    required this.description,
    required this.folderName,
    required this.descriptionQuery,
    required this.folderNameQuery,
    required this.status,
    required this.topic,
  });

  Map<String, dynamic> toMap() {
    return {
      'createdBy': createdBy,
      'createdOn': createdOn.toString(),
      'description': description,
      'folderName': folderName,
      'folderNameQuery': folderNameQuery,
      'descriptionQuery': descriptionQuery,
      'status': status,
      'topic': topic,
    };
  }

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      createdBy: map['createdBy'],
      createdOn: DateTime.parse(map['createdOn']),
      description: map['description'],
      status: map['status'],
      folderNameQuery: map['folderNameQuery'],
      descriptionQuery: map['descriptionQuery'],
      folderName: map['folderName'],
      topic: List<Topic>.from(map['topics'].map((x) => Topic.fromMap(x))),
    );
  }
}
