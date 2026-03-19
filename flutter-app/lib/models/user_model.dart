import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String username;

  @HiveField(2)
  String email;

  @HiveField(3)
  String? avatar;

  @HiveField(4)
  String role; // 'teacher' | 'student' | 'parent'

  @HiveField(5)
  DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    required this.role,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      avatar: json['avatar'],
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
