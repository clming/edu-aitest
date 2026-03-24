import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/homework_detail_screen.dart';
import '../screens/student_list_screen.dart';
import '../screens/report_screen.dart';

/// 路由配置
/// 使用 GoRouter 进行路由管理，支持深度链接和路由守卫

// 导航键
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

/// 路由提供者
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: true,
    
    // 路由守卫
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      
      // 未登录且不在登录/注册页面，重定向到登录页
      if (!isAuthenticated && !isLoggingIn && !isRegistering) {
        return '/login';
      }
      
      // 已登录且在登录/注册页面，重定向到首页
      if (isAuthenticated && (isLoggingIn || isRegistering)) {
        return '/home';
      }
      
      return null;
    },
    
    routes: [
      // 认证路由
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // 主应用路由 (需要登录)
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => child,
        routes: [
          // 首页
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          
          // 作业详情
          GoRoute(
            path: '/home/homework/:id',
            name: 'homework-detail',
            builder: (context, state) {
              final homeworkId = int.parse(state.pathParameters['id']!);
              return HomeworkDetailScreen(homeworkId: homeworkId);
            },
          ),
          
          // 学生列表
          GoRoute(
            path: '/home/students',
            name: 'students',
            builder: (context, state) => const StudentListScreen(),
          ),
          
          // 学习报告
          GoRoute(
            path: '/home/report',
            name: 'report',
            builder: (context, state) => const ReportScreen(),
          ),
        ],
      ),
    ],
    
    // 错误页面
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('页面不存在')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '页面不存在：${state.uri.path}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// 路由扩展方法
extension RouterExtension on BuildContext {
  /// 跳转到作业详情
  void goToHomeworkDetail(int homeworkId) {
    go('/home/homework/$homeworkId');
  }
  
  /// 跳转到学生列表
  void goToStudents() {
    go('/home/students');
  }
  
  /// 跳转到学习报告
  void goToReport() {
    go('/home/report');
  }
  
  /// 跳转到登录页
  void goToLogin() {
    go('/login');
  }
  
  /// 跳转到注册页
  void goToRegister() {
    go('/register');
  }
  
  /// 跳转到首页
  void goToHome() {
    go('/home');
  }
  
  /// 返回上一页
  void goBack() {
    pop();
  }
}
