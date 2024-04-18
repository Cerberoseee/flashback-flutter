import 'package:flutter_final/src/model/Vocabulary.dart';

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
      'createdOn': createdOn,
      'status': status,
      'topicName': topicName,
      'offset': offset,
      'total': total,
      'vocabulary': vocabulary?.toMap(),
    };
  }
}