class Topic {
  String createdBy;
  DateTime createdOn;
  String description;
  String status;
  String topicName;
  String descriptionQuery;
  String topicNameQuery;

  List<Map<String, dynamic>>? vocabularies;

  Topic({
    required this.createdBy,
    required this.createdOn,
    required this.status,
    required this.description,
    required this.topicName,
    required this.descriptionQuery,
    required this.topicNameQuery,
    this.vocabularies,
  });

  Map<String, dynamic> toMap() {
    return {
      'createdBy': createdBy,
      'createdOn': createdOn.toString(),
      'status': status,
      'description': description,
      'topicName': topicName,
      'descriptionQuery': descriptionQuery,
      'topicNameQuery': topicNameQuery,
      'vocabularies': vocabularies,
    };
  }

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      createdBy: map['createdBy'],
      createdOn: map['createdOn'],
      status: map['status'],
      description: map['description'],
      topicName: map['topicName'],
      descriptionQuery: map['descriptionQuery'],
      topicNameQuery: map['topicNameQuery'],
      vocabularies: map['vocabularies'],
    );
  }
}
