/// 工具函数库
/// 
/// 提供常用的工具函数和扩展方法

import 'dart:io';
import 'package:flutter/foundation.dart';

/// 环境配置
class Environment {
  static const String dev = 'development';
  static const String prod = 'production';
  
  /// 当前环境
  static String get current {
    return kDebugMode ? dev : prod;
  }
  
  /// 是否为开发环境
  static bool get isDev => kDebugMode;
  
  /// 是否为生产环境
  static bool get isProd => !kDebugMode;
  
  /// API 基础 URL
  static String get apiUrl {
    if (kDebugMode) {
      // 开发环境
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080/api/v1'; // Android 模拟器
      } else if (Platform.isIOS) {
        return 'http://localhost:8080/api/v1'; // iOS 模拟器
      } else {
        return 'http://localhost:8080/api/v1'; // Web
      }
    } else {
      // 生产环境
      return 'https://api.edu-assistant.com/api/v1';
    }
  }
}

/// 字符串扩展
extension StringExtension on String {
  /// 判断是否为空或空白
  bool get isNullOrEmpty => trim().isEmpty;
  
  /// 判断是否为有效的邮箱
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
  
  /// 判断是否为有效的手机号 (中国大陆)
  bool get isValidPhone {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(this);
  }
  
  /// 判断是否为有效的密码 (至少 6 位)
  bool get isValidPassword {
    return length >= 6;
  }
  
  /// 首字母大写
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
  
  /// 隐藏中间部分 (用于手机号、邮箱等)
  String mask({int start = 3, int end = 4}) {
    if (length <= start + end) return this;
    return '${substring(0, start)}****${substring(length - end)}';
  }
}

/// 列表扩展
extension ListExtension<T> on List<T> {
  /// 安全获取元素
  T? safeGet(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }
  
  /// 分组
  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    final Map<K, List<T>> grouped = {};
    for (final item in this) {
      final key = keySelector(item);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }
  
  /// 去重
  List<T> distinct([dynamic Function(T)? keySelector]) {
    if (keySelector == null) {
      return toSet().toList();
    }
    
    final seen = <dynamic>{};
    final result = <T>[];
    
    for (final item in this) {
      final key = keySelector(item);
      if (!seen.contains(key)) {
        seen.add(key);
        result.add(item);
      }
    }
    
    return result;
  }
}

/// DateTime 扩展
extension DateTimeExtension on DateTime {
  /// 格式化日期为 YYYY-MM-DD
  String formatDate() {
    return '${year}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
  
  /// 格式化时间为 HH:mm
  String formatTime() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
  
  /// 格式化为日期时间
  String formatDateTime() {
    return '${formatDate()} ${formatTime()}';
  }
  
  /// 格式化相对时间
  String formatRelative() {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
  
  /// 判断是否是今天
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  /// 判断是否是昨天
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
  
  /// 判断是否是明天
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }
  
  /// 判断是否已过期
  bool get isOverdue {
    return isBefore(DateTime.now());
  }
  
  /// 判断是否紧急 (3 天内)
  bool get isUrgent {
    final difference = difference(DateTime.now()).inDays;
    return difference >= 0 && difference <= 3;
  }
  
  /// 获取这周的开始日期 (周一)
  DateTime get weekStart {
    final monday = subtract(Duration(days: weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }
  
  /// 获取这周的结束日期 (周日)
  DateTime get weekEnd {
    final sunday = add(Duration(days: 7 - weekday));
    return DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59);
  }
  
  /// 获取这个月的开始日期
  DateTime get monthStart {
    return DateTime(year, month, 1);
  }
  
  /// 获取这个月的结束日期
  DateTime get monthEnd {
    return DateTime(year, month + 1, 0, 23, 59, 59);
  }
}

/// 数字扩展
extension NumExtension on num {
  /// 格式化为货币 (人民币)
  String toCurrency() {
    return '¥${toStringAsFixed(2)}';
  }
  
  /// 格式化为百分比
  String toPercentage({int decimals = 1}) {
    return '${toStringAsFixed(decimals)}%';
  }
  
  /// 格式化数字 (添加千位分隔符)
  String formatNumber() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

/// 布尔扩展
extension BoolExtension on bool {
  /// 如果是 true 则返回 onTrue，否则返回 onFalse
  T fold<T>(T onTrue, T onFalse) {
    return this ? onTrue : onFalse;
  }
  
  /// 如果是 true 则执行 action
  void ifTrue(VoidCallback action) {
    if (this) {
      action();
    }
  }
  
  /// 如果是 false 则执行 action
  void ifFalse(VoidCallback action) {
    if (!this) {
      action();
    }
  }
}

/// 验证工具
class Validator {
  /// 验证用户名 (3-20 位字母数字下划线)
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入用户名';
    }
    if (value.length < 3) {
      return '用户名至少 3 个字符';
    }
    if (value.length > 20) {
      return '用户名最多 20 个字符';
    }
    if (!RegExp(r'^[\w\u4e00-\u9fa5]+$').hasMatch(value)) {
      return '用户名只能包含字母、数字、下划线和中文';
    }
    return null;
  }
  
  /// 验证邮箱
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱';
    }
    if (!value.isValidEmail) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }
  
  /// 验证密码
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码至少 6 个字符';
    }
    return null;
  }
  
  /// 验证确认密码
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return '请确认密码';
    }
    if (value != password) {
      return '两次输入的密码不一致';
    }
    return null;
  }
  
  /// 验证手机号
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入手机号';
    }
    if (!value.isValidPhone) {
      return '请输入有效的手机号';
    }
    return null;
  }
  
  /// 验证必填字段
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '请输入$fieldName';
    }
    return null;
  }
  
  /// 验证长度
  static String? validateLength(String? value, int min, int max, String fieldName) {
    if (value == null || value.isEmpty) {
      return '请输入$fieldName';
    }
    if (value.length < min) {
      return '$fieldName 至少$min个字符';
    }
    if (value.length > max) {
      return '$fieldName 最多$max个字符';
    }
    return null;
  }
}

/// 防抖函数
class Debouncer {
  final int milliseconds;
  Timer? _timer;
  
  Debouncer({this.milliseconds = 500});
  
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
  
  void dispose() {
    _timer?.cancel();
  }
}

/// 节流函数
class Throttler {
  final int milliseconds;
  DateTime? _lastExecution;
  Timer? _timer;
  
  Throttler({this.milliseconds = 500});
  
  void run(VoidCallback action) {
    final now = DateTime.now();
    
    if (_lastExecution == null || 
        now.difference(_lastExecution!).inMilliseconds >= milliseconds) {
      _lastExecution = now;
      action();
    } else if (_timer == null || !_timer!.isActive) {
      _timer = Timer(
        Duration(milliseconds: milliseconds),
        () {
          _lastExecution = DateTime.now();
          action();
        },
      );
    }
  }
  
  void dispose() {
    _timer?.cancel();
  }
}
