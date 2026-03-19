import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/homework_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late Box<User> _userBox;
  late Box<Homework> _homeworkBox;

  Future<void> init() async {
    await Hive.initFlutter();
    
    // 注册适配器
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HomeworkAdapter());
    }

    // 打开盒子
    _userBox = await Hive.openBox<User>('users');
    _homeworkBox = await Hive.openBox<Homework>('homework');
  }

  // User 相关操作
  Future<void> saveUser(User user) async {
    await _userBox.put(user.id, user);
  }

  User? getUser(int id) {
    return _userBox.get(id);
  }

  List<User> getAllUsers() {
    return _userBox.values.toList();
  }

  Future<void> deleteUser(int id) async {
    await _userBox.delete(id);
  }

  Future<void> clearUsers() async {
    await _userBox.clear();
  }

  // Homework 相关操作
  Future<void> saveHomework(Homework homework) async {
    await _homeworkBox.put(homework.id, homework);
  }

  Homework? getHomework(int id) {
    return _homeworkBox.get(id);
  }

  List<Homework> getAllHomework() {
    return _homeworkBox.values.toList();
  }

  List<Homework> getHomeworkBySubject(String subject) {
    return _homeworkBox.values.where((h) => h.subject == subject).toList();
  }

  List<Homework> getPendingHomework() {
    return _homeworkBox.values.where((h) => !h.isCompleted).toList();
  }

  Future<void> deleteHomework(int id) async {
    await _homeworkBox.delete(id);
  }

  Future<void> clearHomework() async {
    await _homeworkBox.clear();
  }

  // 通用操作
  Future<void> clearAll() async {
    await _userBox.clear();
    await _homeworkBox.clear();
  }

  Future<void> close() async {
    await _userBox.close();
    await _homeworkBox.close();
  }
}
