import 'package:flutter_final/src/models/vocab_model.dart';

class Topic {
  String createdBy;
  String createdOn;
  String description;
  bool status;
  String topicName;
  Vocabulary? vocabulary;

  Topic({
    required this.createdBy,
    required this.createdOn,
    required this.status,
    required this.description,
    required this.topicName,
    this.vocabulary,
  });

  Map<String, dynamic> toMap() {
    return {
      'createdBy': createdBy,
      'createdOn': createdOn.toString(),
      'status': status,
      'description': description,
      'topicName': topicName,
      'vocabulary': vocabulary?.toMap(),
    };
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      createdBy: map['createdBy']['name'],
      createdOn: map['createdOn'],
      status: map['status'],
      description: map['description'],
      topicName: map['topicName'],
      vocabulary: map['vocabulary'] != null ? Vocabulary.fromMap(map['vocabulary']) : null,
    );
  }
}
