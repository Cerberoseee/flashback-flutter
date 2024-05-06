import 'package:flutter_final/src/models/vocab_model.dart';

class Topic{
  String createdBy;
  String createdOn;
  bool status;
  String topicName;
  String offset;
  String total;
  Vocabulary? vocabulary;

  Topic({
    required this.createdBy,
    required this.createdOn,
    required this.status,
    required this.topicName,
    required this.offset,
    required this.total,
    this.vocabulary,
  });

  Map<String, dynamic> toMap() {
    return {
      'createdBy': createdBy,
      'createdOn': createdOn.toString(),
      'status': status,
      'topicName': topicName,
      'offset': offset,
      'total': total,
      'vocabulary': vocabulary?.toMap(),
    };
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      createdBy: map['createdBy']['name'],
      createdOn: map['createdOn'],
      status: map['status'],
      topicName: map['topicName'],
      offset: map['offset'],
      total: map['total'],
      vocabulary: map['vocabulary'] != null
          ? Vocabulary.fromMap(map['vocabulary'])
          : null,
    );
  }

}