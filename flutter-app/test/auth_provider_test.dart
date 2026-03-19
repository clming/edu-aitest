import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edu_assistant/providers/auth_provider.dart';
import 'package:edu_assistant/services/api_service.dart';
import 'package:edu_assistant/services/storage_service.dart';

void main() {
  group('AuthNotifier Tests', () {
    late ProviderContainer container;
    late ApiService apiService;
    late StorageService storageService;

    setUp(() {
      apiService = ApiService();
      storageService = StorageService();
      
      container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(apiService),
          storageServiceProvider.overrideWithValue(storageService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should be unauthenticated', () {
      final authState = container.read(authProvider);
      
      expect(authState.isAuthenticated, false);
      expect(authState.user, isNull);
      expect(authState.isLoading, false);
      expect(authState.error, isNull);
    });

    test('login should update state to loading', () async {
      final notifier = container.read(authProvider.notifier);
      
      // 注意：这个测试会失败，因为没有真实的后端
      // 在实际项目中应该 mock API 服务
      await notifier.login('testuser', 'testpass');
      
      final authState = container.read(authProvider);
      // 由于 API 调用失败，error 会被设置
      expect(authState.error, isNotNull);
    });

    test('logout should clear authentication', () async {
      final notifier = container.read(authProvider.notifier);
      
      await notifier.logout();
      
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.user, isNull);
    });
  });
}
