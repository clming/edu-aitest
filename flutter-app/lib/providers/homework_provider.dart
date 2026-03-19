import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/homework_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class HomeworkState {
  final bool isLoading;
  final List<Homework> homeworkList;
  final String? error;

  HomeworkState({
    this.isLoading = false,
    this.homeworkList = const [],
    this.error,
  });

  HomeworkState copyWith({
    bool? isLoading,
    List<Homework>? homeworkList,
    String? error,
  }) {
    return HomeworkState(
      isLoading: isLoading ?? this.isLoading,
      homeworkList: homeworkList ?? this.homeworkList,
      error: error ?? this.error,
    );
  }
}

class HomeworkNotifier extends StateNotifier<HomeworkState> {
  final ApiService _apiService;
  final StorageService _storageService;

  HomeworkNotifier(this._apiService, this._storageService) 
    : super(HomeworkState());

  Future<void> loadHomework() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.getHomeworkList();
      final homeworkList = (response as List)
          .map((json) => Homework.fromJson(json))
          .toList();
      
      // 保存到本地存储
      for (final homework in homeworkList) {
        await _storageService.saveHomework(homework);
      }
      
      state = HomeworkState(
        isLoading: false,
        homeworkList: homeworkList,
      );
    } catch (e) {
      // 如果 API 失败，尝试从本地加载
      final localHomework = _storageService.getAllHomework();
      state = HomeworkState(
        isLoading: false,
        homeworkList: localHomework,
        error: e.toString(),
      );
    }
  }

  Future<void> createHomework({
    required String title,
    required String description,
    required String subject,
    required DateTime deadline,
    int? studentId,
  }) async {
    try {
      final response = await _apiService.createHomework(
        title: title,
        description: description,
        subject: subject,
        deadline: deadline,
        studentId: studentId,
      );
      
      final homework = Homework.fromJson(response);
      await _storageService.saveHomework(homework);
      
      state = state.copyWith(
        homeworkList: [...state.homeworkList, homework],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateHomework(int id, {
    String? title,
    String? description,
    String? subject,
    DateTime? deadline,
    bool? isCompleted,
  }) async {
    try {
      await _apiService.updateHomework(
        id,
        title: title,
        description: description,
        subject: subject,
        deadline: deadline,
        isCompleted: isCompleted,
      );
      
      final index = state.homeworkList.indexWhere((h) => h.id == id);
      if (index != -1) {
        final updated = state.homeworkList[index].copyWith(
          title: title ?? state.homeworkList[index].title,
          description: description ?? state.homeworkList[index].description,
          subject: subject ?? state.homeworkList[index].subject,
          deadline: deadline ?? state.homeworkList[index].deadline,
          isCompleted: isCompleted ?? state.homeworkList[index].isCompleted,
        );
        
        final newList = [...state.homeworkList];
        newList[index] = updated;
        
        await _storageService.saveHomework(updated);
        
        state = state.copyWith(homeworkList: newList);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteHomework(int id) async {
    try {
      await _apiService.deleteHomework(id);
      await _storageService.deleteHomework(id);
      
      state = state.copyWith(
        homeworkList: state.homeworkList.where((h) => h.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  List<Homework> getPendingHomework() {
    return state.homeworkList.where((h) => !h.isCompleted).toList();
  }

  List<Homework> getCompletedHomework() {
    return state.homeworkList.where((h) => h.isCompleted).toList();
  }
}

final homeworkProvider = StateNotifierProvider<HomeworkNotifier, HomeworkState>((ref) {
  return HomeworkNotifier(
    ref.watch(apiServiceProvider),
    ref.watch(storageServiceProvider),
  );
});
