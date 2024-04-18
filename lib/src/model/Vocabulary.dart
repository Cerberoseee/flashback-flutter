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
}