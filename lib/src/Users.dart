class Users{
  String avatarUrl;
  String email;
  String language;
  String name;
  String status;
  String username;

  Users({
    required this.avatarUrl,
    required this.email,
    required this.language,
    required this.name,
    required this.status,
    required this.username,
  });

   Map<String, dynamic> toMap() {
    return {
      'avatarUrl': avatarUrl,
      'email': email,
      'language': language,
      'name': name,
      'status': status,
      'username': username,
    };
  }
}