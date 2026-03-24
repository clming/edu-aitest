import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/theme_config.dart';
import 'config/router_config.dart';
import 'providers/auth_provider.dart';
import 'services/storage_service.dart';

/// 教育助手应用入口
/// 
/// 支持 iOS、Android、Web 三端合一
/// 参考作业帮家长版设计
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化存储
  final storageService = StorageService();
  await storageService.init();

  runApp(
    const ProviderScope(
      child: EduAssistantApp(),
    ),
  );
}

/// 应用根组件
class EduAssistantApp extends ConsumerWidget {
  const EduAssistantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听认证状态变化
    ref.listen<AuthState>(
      authProvider,
      (previous, next) {
        if (previous?.isAuthenticated != next.isAuthenticated) {
          // 认证状态改变时刷新路由
          // GoRouter 会自动处理重定向
        }
      },
    );

    // 初始化时检查认证状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuth();
    });

    return MaterialApp.router(
      title: '教育助手',
      debugShowCheckedModeBanner: false,
      
      // 应用主题
      theme: AppTheme.lightTheme,
      
      // 路由配置
      routerConfig: ref.watch(goRouterProvider),
    );
  }
}
