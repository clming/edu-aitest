import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthNotifier(this._apiService, this._storageService) 
    : super(AuthState());

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.login(username, password);
      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;
      
      await _apiService.setToken(token);
      
      final user = User.fromJson(userData);
      await _storageService.saveUser(user);
      
      state = AuthState(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.register(
        username: username,
        email: email,
        password: password,
        role: role,
      );
      
      final token = response['token'] as String;
      final userData = response['user'] as Map<String, dynamic>;
      
      await _apiService.setToken(token);
      
      final user = User.fromJson(userData);
      await _storageService.saveUser(user);
      
      state = AuthState(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // 忽略登出错误
    }
    
    await _storageService.clearUsers();
    state = AuthState();
  }

  Future<void> checkAuth() async {
    final token = await _apiService.getToken();
    
    if (token != null) {
      final users = _storageService.getAllUsers();
      if (users.isNotEmpty) {
        state = AuthState(
          isAuthenticated: true,
          user: users.first,
        );
      }
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(apiServiceProvider),
    ref.watch(storageServiceProvider),
  );
});
