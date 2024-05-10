class TopicUserInfo {
  String topicId;
  String userId;
  int lastScore;
  List<Map<String, dynamic>>? vocabStatus;

  TopicUserInfo({
    required this.topicId,
    required this.userId,
    this.lastScore = 0,
    this.vocabStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'topicId': topicId,
      'userId': userId,
      'lastScore': lastScore,
      'vocabStatus': vocabStatus,
    };
  }

  factory TopicUserInfo.fromMap(Map<String, dynamic> map) {
    return TopicUserInfo(
      topicId: map['topicId'],
      userId: map['userId'],
      lastScore: map['lastScore'],
      vocabStatus: map['vocabStatus'],
    );
  }
}
