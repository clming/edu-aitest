import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edu_assistant/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // 构建应用
    await tester.pumpWidget(
      const ProviderScope(
        child: EduAssistantApp(),
      ),
    );

    // 验证应用启动
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Login screen displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: EduAssistantApp(),
      ),
    );

    // 等待异步操作
    await tester.pump();

    // 验证登录界面元素
    expect(find.text('教育助手'), findsOneWidget);
    expect(find.text('欢迎回来，请登录您的账号'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);
    expect(find.text('登录'), findsOneWidget);
  });

  testWidgets('Login form validation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: EduAssistantApp(),
      ),
    );

    await tester.pump();

    // 尝试不输入任何内容直接登录
    await tester.tap(find.text('登录'));
    await tester.pump();

    // 应该显示验证错误
    expect(find.text('请输入用户名'), findsOneWidget);
  });
}
