class UserTopicScore {
  String topicId;
  String userId;
  int attempt;
  int correctAnswer;
  int timeDone;

  UserTopicScore({
    required this.topicId,
    required this.userId,
    this.attempt = 0,
    this.correctAnswer = 0,
    this.timeDone = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'topicId': topicId,
      'userId': userId,
      'attempt': attempt,
      'correctAnswer': correctAnswer,
      'timeDone': timeDone,
    };
  }

  factory UserTopicScore.fromMap(Map<String, dynamic> map) {
    return UserTopicScore(
      topicId: map['topicId'],
      userId: map['userId'],
      attempt: map['attempt'],
      correctAnswer: map['correctAnswer'],
      timeDone: map['timeDone'],
    );
  }
}
