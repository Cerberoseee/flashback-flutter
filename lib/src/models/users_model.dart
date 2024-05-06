class Users {
  String avatarUrl;
  String email;
  String name;
  String username;

  Users({
    required this.avatarUrl,
    required this.email,
    required this.name,
    required this.username,
  });

  Map<String, dynamic> toMap() {
    return {
      'avatarUrl': avatarUrl,
      'email': email,
      'name': name,
      'username': username,
    };
  }

  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      avatarUrl: map['avatarUrl'],
      name: map['name'],
      email: map['email'],
      username: map['username'],
    );
  }
}
