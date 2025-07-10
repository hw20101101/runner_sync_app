class User {
  final String email;
  final String token;
  final int userId;

  User({required this.email, required this.token, required this.userId});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      token: json['token'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'token': token,
      'user_id': userId,
    };
  }
}
