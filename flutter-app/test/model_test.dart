import 'package:flutter_test/flutter_test.dart';
import 'package:edu_assistant/models/user_model.dart';
import 'package:edu_assistant/models/homework_model.dart';

void main() {
  group('User Model Tests', () {
    test('User fromJson should create User object', () {
      final json = {
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
        'avatar': 'https://example.com/avatar.jpg',
        'role': 'student',
        'created_at': '2024-01-01T00:00:00.000Z',
      };
      
      final user = User.fromJson(json);
      
      expect(user.id, 1);
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
      expect(user.avatar, 'https://example.com/avatar.jpg');
      expect(user.role, 'student');
      expect(user.createdAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
    });
    
    test('User toJson should return correct map', () {
      final user = User(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        avatar: null,
        role: 'teacher',
        createdAt: DateTime(2024, 1, 1),
      );
      
      final json = user.toJson();
      
      expect(json['id'], 1);
      expect(json['username'], 'testuser');
      expect(json['email'], 'test@example.com');
      expect(json['avatar'], null);
      expect(json['role'], 'teacher');
      expect(json['created_at'], '2024-01-01T00:00:00.000');
    });
    
    test('User with null avatar should work', () {
      final json = {
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
        'role': 'parent',
        'created_at': '2024-01-01T00:00:00.000Z',
      };
      
      final user = User.fromJson(json);
      
      expect(user.avatar, isNull);
    });
  });
  
  group('Homework Model Tests', () {
    test('Homework fromJson should create Homework object', () {
      final json = {
        'id': 1,
        'title': 'Math Homework',
        'description': 'Complete exercises 1-10',
        'subject': '数学',
        'deadline': '2024-12-31T23:59:59.000Z',
        'is_completed': false,
        'teacher_id': 1,
        'student_id': 2,
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-02T00:00:00.000Z',
      };
      
      final homework = Homework.fromJson(json);
      
      expect(homework.id, 1);
      expect(homework.title, 'Math Homework');
      expect(homework.description, 'Complete exercises 1-10');
      expect(homework.subject, '数学');
      expect(homework.deadline, DateTime.parse('2024-12-31T23:59:59.000Z'));
      expect(homework.isCompleted, false);
      expect(homework.teacherId, 1);
      expect(homework.studentId, 2);
      expect(homework.createdAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
      expect(homework.updatedAt, DateTime.parse('2024-01-02T00:00:00.000Z'));
    });
    
    test('Homework toJson should return correct map', () {
      final homework = Homework(
        id: 1,
        title: 'Test Homework',
        description: 'Test Description',
        subject: '英语',
        deadline: DateTime(2024, 12, 31, 23, 59, 59),
        isCompleted: true,
        teacherId: 1,
        studentId: 2,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );
      
      final json = homework.toJson();
      
      expect(json['id'], 1);
      expect(json['title'], 'Test Homework');
      expect(json['description'], 'Test Description');
      expect(json['subject'], '英语');
      expect(json['is_completed'], true);
      expect(json['teacher_id'], 1);
      expect(json['student_id'], 2);
    });
    
    test('Homework with null updatedAt should work', () {
      final json = {
        'id': 1,
        'title': 'Test',
        'description': 'Test',
        'subject': '数学',
        'deadline': '2024-12-31T23:59:59.000Z',
        'is_completed': false,
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': null,
      };
      
      final homework = Homework.fromJson(json);
      
      expect(homework.updatedAt, isNull);
    });
    
    test('Homework default isCompleted should be false', () {
      final homework = Homework(
        id: 1,
        title: 'Test',
        description: 'Test',
        subject: '数学',
        deadline: DateTime.now(),
        createdAt: DateTime.now(),
      );
      
      expect(homework.isCompleted, false);
    });
  });
  
  group('Model Edge Cases', () {
    test('User with empty username should work', () {
      final json = {
        'id': 1,
        'username': '',
        'email': 'test@example.com',
        'role': 'student',
        'created_at': '2024-01-01T00:00:00.000Z',
      };
      
      final user = User.fromJson(json);
      
      expect(user.username, '');
    });
    
    test('Homework with empty description should work', () {
      final json = {
        'id': 1,
        'title': 'Test',
        'description': '',
        'subject': '数学',
        'deadline': '2024-12-31T23:59:59.000Z',
        'is_completed': false,
        'created_at': '2024-01-01T00:00:00.000Z',
      };
      
      final homework = Homework.fromJson(json);
      
      expect(homework.description, '');
    });
  });
}
