class Vocabulary{
  String en;
  bool status;
  String vi;

  Vocabulary({
    required this.en,
    required this.status,
    required this.vi
  });

  Map<String, dynamic> toMap(){
    return {
      'en': en,
      'status': status,
      'vi': vi,
    };
  }

  factory Vocabulary.fromMap(Map<String, dynamic> map) {
    return Vocabulary(
      en: map['en'],
      status: map['status'],
      vi: map['vi']
    );
  }
}