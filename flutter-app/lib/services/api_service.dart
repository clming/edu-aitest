import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  late Dio _dio;
  String? _token;
  
  static const String baseUrl = 'http://localhost:8080/api/v1';

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_token != null) {
          options.headers['Authorization'] = _token;
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    ));
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    if (_token != null) {
      return _token;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // 认证相关
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'username': username,
      'email': email,
      'password': password,
      'role': role,
    });
    return response.data;
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
    await clearToken();
  }

  // 作业相关
  Future<List<dynamic>> getHomeworkList() async {
    final response = await _dio.get('/homework');
    return response.data;
  }

  Future<Map<String, dynamic>> getHomeworkDetail(int id) async {
    final response = await _dio.get('/homework/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> createHomework({
    required String title,
    required String description,
    required String subject,
    required DateTime deadline,
    int? studentId,
  }) async {
    final response = await _dio.post('/homework', data: {
      'title': title,
      'description': description,
      'subject': subject,
      'deadline': deadline.toIso8601String(),
      'student_id': studentId,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> updateHomework(int id, {
    String? title,
    String? description,
    String? subject,
    DateTime? deadline,
    bool? isCompleted,
  }) async {
    final response = await _dio.put('/homework/$id', data: {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (subject != null) 'subject': subject,
      if (deadline != null) 'deadline': deadline.toIso8601String(),
      if (isCompleted != null) 'is_completed': isCompleted,
    });
    return response.data;
  }

  Future<void> deleteHomework(int id) async {
    await _dio.delete('/homework/$id');
  }

  // 学生相关
  Future<List<dynamic>> getStudentList() async {
    final response = await _dio.get('/students');
    return response.data;
  }

  Future<Map<String, dynamic>> getStudentDetail(int id) async {
    final response = await _dio.get('/students/$id');
    return response.data;
  }

  // 学习报告
  Future<Map<String, dynamic>> getWeeklyReport() async {
    final response = await _dio.get('/reports/weekly');
    return response.data;
  }

  Future<Map<String, dynamic>> getMonthlyReport() async {
    final response = await _dio.get('/reports/monthly');
    return response.data;
  }
}
