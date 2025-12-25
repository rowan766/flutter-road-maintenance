class User {
  final String id;
  final String username;
  final String token;
  final String? avatar;

  User({
    required this.id,
    required this.username,
    required this.token,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      token: json['token'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'token': token,
      'avatar': avatar,
    };
  }
}
