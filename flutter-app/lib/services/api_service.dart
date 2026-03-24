import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// API 服务类
/// 
/// 封装 Dio HTTP 客户端，提供：
/// - Token 自动管理和刷新
/// - 请求/响应拦截
/// - 错误处理和重试机制
/// - 统一的 API 接口
class ApiService {
  late Dio _dio;
  String? _token;
  String? _refreshToken;
  bool _isRefreshing = false;
  final List<Function(String)> _tokenListeners = [];
  
  static const String baseUrl = 'http://localhost:8080/api/v1';
  static const int maxRetries = 3;
  static const int retryDelayMs = 1000;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) => status != null && status < 500,
    ));

    // 添加请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 自动添加 Token
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        
        if (kDebugMode) {
          debugPrint('📤 Request: ${options.method} ${options.uri}');
          debugPrint('Headers: ${options.headers}');
          if (options.data != null) {
            debugPrint('Data: ${options.data}');
          }
        }
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint('📥 Response: ${response.statusCode} ${response.requestOptions.uri}');
        }
        return handler.next(response);
      },
      onError: (error, handler) async {
        if (kDebugMode) {
          debugPrint('❌ Error: ${error.type} - ${error.message}');
        }
        
        // 处理 401 错误 (Token 过期)
        if (error.response?.statusCode == 401) {
          try {
            final newToken = await _refreshTokenIfNeeded();
            if (newToken != null) {
              // 重试原请求
              final response = await _retryRequest(error.requestOptions);
              return handler.resolve(response);
            }
          } catch (e) {
            // Token 刷新失败，清除 Token
            await clearToken();
          }
        }
        
        return handler.next(error);
      },
    ));
    
    // 添加重试拦截器
    _dio.interceptors.add(RetriesInterceptor());
  }
  
  /// 添加 Token 监听器
  void addTokenListener(Function(String) listener) {
    _tokenListeners.add(listener);
  }
  
  /// 移除 Token 监听器
  void removeTokenListener(Function(String) listener) {
    _tokenListeners.remove(listener);
  }
  
  /// 通知所有监听器 Token 已更新
  void _notifyTokenListeners(String token) {
    for (final listener in _tokenListeners) {
      try {
        listener(token);
      } catch (e) {
        debugPrint('Token listener error: $e');
      }
    }
  }

  /// 设置 Token
  Future<void> setToken(String token, {String? refreshToken}) async {
    _token = token;
    _refreshToken = refreshToken;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
    }
    
    _notifyTokenListeners(token);
  }

  /// 获取 Token
  Future<String?> getToken() async {
    if (_token != null) {
      return _token;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  /// 获取 Refresh Token
  Future<String?> getRefreshToken() async {
    if (_refreshToken != null) {
      return _refreshToken;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  /// 清除 Token
  Future<void> clearToken() async {
    _token = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
  }
  
  /// 刷新 Token
  Future<String?> _refreshTokenIfNeeded() async {
    if (_isRefreshing) {
      // 等待 Token 刷新完成
      await Future.delayed(const Duration(milliseconds: 500));
      return _token;
    }
    
    _isRefreshing = true;
    
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        return null;
      }
      
      final response = await _dio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });
      
      final newToken = response.data['token'] as String;
      final newRefreshToken = response.data['refresh_token'] as String?;
      
      await setToken(newToken, refreshToken: newRefreshToken);
      
      return newToken;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      return null;
    } finally {
      _isRefreshing = false;
    }
  }
  
  /// 重试请求
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // ==================== 认证相关 API ====================
  
  /// 登录
  /// 
  /// [username] 用户名
  /// [password] 密码
  /// 
  /// 返回包含 token 和用户信息的响应
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });
      
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String?;
        final refreshToken = data['refresh_token'] as String?;
        
        if (token != null) {
          await setToken(token, refreshToken: refreshToken);
        }
        
        return data;
      }
      
      throw ApiException('登录响应格式错误');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 注册
  /// 
  /// [username] 用户名
  /// [email] 邮箱
  /// [password] 密码
  /// [role] 角色 (student|teacher|parent)
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      });
      
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String?;
        final refreshToken = data['refresh_token'] as String?;
        
        if (token != null) {
          await setToken(token, refreshToken: refreshToken);
        }
        
        return data;
      }
      
      throw ApiException('注册响应格式错误');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      // 忽略登出错误
    } finally {
      await clearToken();
    }
  }
  
  /// 获取当前用户信息
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// 修改密码
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.put('/auth/password', data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      });
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ==================== 作业相关 API ====================
  
  /// 获取作业列表
  /// 
  /// [subject] 可选，按科目筛选
  /// [status] 可选，按状态筛选 (pending|completed|all)
  /// [page] 页码，默认 1
  /// [pageSize] 每页数量，默认 20
  Future<List<dynamic>> getHomeworkList({
    String? subject,
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get('/homework', queryParameters: {
        if (subject != null) 'subject': subject,
        if (status != null) 'status': status,
        'page': page,
        'page_size': pageSize,
      });
      
      if (response.data is List) {
        return response.data as List;
      }
      
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        return data['items'] as List? ?? [];
      }
      
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 获取作业详情
  Future<Map<String, dynamic>> getHomeworkDetail(int id) async {
    try {
      final response = await _dio.get('/homework/$id');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 创建作业
  Future<Map<String, dynamic>> createHomework({
    required String title,
    required String description,
    required String subject,
    required DateTime deadline,
    int? studentId,
  }) async {
    try {
      final response = await _dio.post('/homework', data: {
        'title': title,
        'description': description,
        'subject': subject,
        'deadline': deadline.toIso8601String(),
        'student_id': studentId,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 更新作业
  Future<Map<String, dynamic>> updateHomework(int id, {
    String? title,
    String? description,
    String? subject,
    DateTime? deadline,
    bool? isCompleted,
    String? comment,
    double? score,
  }) async {
    try {
      final response = await _dio.put('/homework/$id', data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (subject != null) 'subject': subject,
        if (deadline != null) 'deadline': deadline.toIso8601String(),
        if (isCompleted != null) 'is_completed': isCompleted,
        if (comment != null) 'comment': comment,
        if (score != null) 'score': score,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 删除作业
  Future<void> deleteHomework(int id) async {
    try {
      await _dio.delete('/homework/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// 提交作业
  Future<Map<String, dynamic>> submitHomework(int id, {
    String? content,
    List<String>? imageUrls,
  }) async {
    try {
      final response = await _dio.post('/homework/$id/submit', data: {
        if (content != null) 'content': content,
        if (imageUrls != null) 'image_urls': imageUrls,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ==================== 学生相关 API ====================
  
  /// 获取学生列表
  /// 
  /// [grade] 可选，按年级筛选
  /// [className] 可选，按班级筛选
  Future<List<dynamic>> getStudentList({
    String? grade,
    String? className,
  }) async {
    try {
      final response = await _dio.get('/students', queryParameters: {
        if (grade != null) 'grade': grade,
        if (className != null) 'class_name': className,
      });
      
      if (response.data is List) {
        return response.data as List;
      }
      
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        return data['items'] as List? ?? [];
      }
      
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 获取学生详情
  Future<Map<String, dynamic>> getStudentDetail(int id) async {
    try {
      final response = await _dio.get('/students/$id');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// 创建学生
  Future<Map<String, dynamic>> createStudent({
    required String name,
    required String grade,
    required String className,
    String? avatar,
  }) async {
    try {
      final response = await _dio.post('/students', data: {
        'name': name,
        'grade': grade,
        'class_name': className,
        if (avatar != null) 'avatar': avatar,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ==================== 学习报告 API ====================
  
  /// 获取周报
  Future<Map<String, dynamic>> getWeeklyReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _dio.get('/reports/weekly', queryParameters: {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// 获取月报
  Future<Map<String, dynamic>> getMonthlyReport({
    int? year,
    int? month,
  }) async {
    try {
      final response = await _dio.get('/reports/monthly', queryParameters: {
        if (year != null) 'year': year,
        if (month != null) 'month': month,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// 获取统计报告
  Future<Map<String, dynamic>> getStatisticsReport() async {
    try {
      final response = await _dio.get('/reports/statistics');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ==================== 错误处理 ====================
  
  /// 处理 Dio 错误
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('网络连接超时，请检查网络设置');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = _getErrorMessage(statusCode, e.response?.data);
        return ApiException(message);
      case DioExceptionType.cancel:
        return ApiException('请求已取消');
      case DioExceptionType.connectionError:
        return ApiException('网络连接失败，请检查网络');
      case DioExceptionType.badCertificate:
        return ApiException('证书错误');
      case DioExceptionType.unknown:
      default:
        return ApiException('网络请求失败：${e.message}');
    }
  }
  
  /// 获取错误消息
  String _getErrorMessage(int? statusCode, dynamic data) {
    // 尝试从响应数据中获取错误消息
    if (data is Map<String, dynamic>) {
      final message = data['message'] as String? ?? 
                      data['error'] as String? ??
                      data['msg'] as String?;
      if (message != null) {
        return message;
      }
    }
    
    // 根据状态码返回默认消息
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '无权访问';
      case 404:
        return '资源不存在';
      case 409:
        return '资源冲突';
      case 500:
        return '服务器错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务不可用';
      default:
        return '请求失败 (状态码：$statusCode)';
    }
  }
}

/// API 异常
class ApiException implements Exception {
  final String message;
  
  ApiException(this.message);
  
  @override
  String toString() => message;
}

/// 重试拦截器
class RetriesInterceptor extends Interceptor {
  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // 只对特定错误进行重试
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      
      final requestOptions = err.requestOptions;
      final retryCount = requestOptions.extra['retryCount'] as int? ?? 0;
      
      if (retryCount < ApiService.maxRetries) {
        // 延迟后重试
        await Future.delayed(
          Duration(milliseconds: ApiService.retryDelayMs * (retryCount + 1)),
        );
        
        try {
          final options = Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
            extra: {
              ...requestOptions.extra,
              'retryCount': retryCount + 1,
            },
          );
          
          final response = await err.requestOptions.dio.request(
            requestOptions.path,
            data: requestOptions.data,
            queryParameters: requestOptions.queryParameters,
            options: options,
          );
          
          return handler.resolve(response);
        } catch (e) {
          // 重试失败，继续传递错误
        }
      }
    }
    
    return handler.next(err);
  }
}
