import 'package:hive/hive.dart';

part 'homework_model.g.dart';

@HiveType(typeId: 1)
class Homework extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String subject;

  @HiveField(4)
  DateTime deadline;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  int? teacherId;

  @HiveField(7)
  int? studentId;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime? updatedAt;

  Homework({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.deadline,
    this.isCompleted = false,
    this.teacherId,
    this.studentId,
    required this.createdAt,
    this.updatedAt,
  });

  factory Homework.fromJson(Map<String, dynamic> json) {
    return Homework(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      subject: json['subject'],
      deadline: DateTime.parse(json['deadline']),
      isCompleted: json['is_completed'] ?? false,
      teacherId: json['teacher_id'],
      studentId: json['student_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'deadline': deadline.toIso8601String(),
      'is_completed': isCompleted,
      'teacher_id': teacherId,
      'student_id': studentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
