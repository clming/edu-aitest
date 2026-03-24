import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../widgets/common_widgets.dart';
import '../config/theme_config.dart';

/// 学生模型
class Student {
  final int id;
  final String name;
  final String avatar;
  final String grade;
  final String className;
  final double averageScore;
  final int completedHomework;
  final int totalHomework;
  
  Student({
    required this.id,
    required this.name,
    required this.avatar,
    required this.grade,
    required this.className,
    required this.averageScore,
    required this.completedHomework,
    required this.totalHomework,
  });
  
  double get completionRate {
    if (totalHomework == 0) return 0;
    return completedHomework / totalHomework * 100;
  }
}

/// 学生列表提供者
final studentListProvider = StateNotifierProvider<StudentListNotifier, StudentListState>((ref) {
  return StudentListNotifier();
});

class StudentListState {
  final bool isLoading;
  final List<Student> students;
  final String? error;
  
  StudentListState({
    this.isLoading = false,
    this.students = const [],
    this.error,
  });
  
  StudentListState copyWith({
    bool? isLoading,
    List<Student>? students,
    String? error,
  }) {
    return StudentListState(
      isLoading: isLoading ?? this.isLoading,
      students: students ?? this.students,
      error: error ?? this.error,
    );
  }
}

class StudentListNotifier extends StateNotifier<StudentListState> {
  StudentListNotifier() : super(StudentListState()) {
    _loadStudents();
  }
  
  Future<void> _loadStudents() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // 模拟数据 - 实际应从 API 加载
      await Future.delayed(const Duration(seconds: 1));
      
      final mockStudents = [
        Student(
          id: 1,
          name: '张三',
          avatar: '',
          grade: '三年级',
          className: '1 班',
          averageScore: 92.5,
          completedHomework: 28,
          totalHomework: 30,
        ),
        Student(
          id: 2,
          name: '李四',
          avatar: '',
          grade: '三年级',
          className: '1 班',
          averageScore: 88.0,
          completedHomework: 25,
          totalHomework: 30,
        ),
        Student(
          id: 3,
          name: '王五',
          avatar: '',
          grade: '三年级',
          className: '2 班',
          averageScore: 95.0,
          completedHomework: 30,
          totalHomework: 30,
        ),
        Student(
          id: 4,
          name: '赵六',
          avatar: '',
          grade: '四年级',
          className: '1 班',
          averageScore: 85.5,
          completedHomework: 22,
          totalHomework: 30,
        ),
        Student(
          id: 5,
          name: '钱七',
          avatar: '',
          grade: '四年级',
          className: '2 班',
          averageScore: 90.0,
          completedHomework: 27,
          totalHomework: 30,
        ),
      ];
      
      state = state.copyWith(
        isLoading: false,
        students: mockStudents,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> refresh() async {
    await _loadStudents();
  }
}

/// 学生列表页面
/// 显示学生列表，支持查看学生详情和成绩
class StudentListScreen extends ConsumerStatefulWidget {
  const StudentListScreen({super.key});

  @override
  ConsumerState<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends ConsumerState<StudentListScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final studentState = ref.watch(studentListProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('学生管理'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '全部学生'),
            Tab(text: '我的孩子'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          if (user?.role == 'teacher')
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => _showAddStudentDialog(),
            ),
        ],
      ),
      body: studentState.isLoading
          ? const LoadingWidget(message: '加载学生列表中...')
          : studentState.students.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.people_outline,
                  title: '暂无学生',
                  subtitle: '添加学生后在这里查看',
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStudentList(studentState.students),
                    _buildMyChildren(user),
                  ],
                ),
    );
  }
  
  Widget _buildStudentList(List<Student> students) {
    final filteredStudents = students.where((student) {
      if (_searchQuery.isEmpty) return true;
      return student.name.contains(_searchQuery) ||
          student.className.contains(_searchQuery);
    }).toList();
    
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(studentListProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredStudents.length,
        itemBuilder: (context, index) {
          final student = filteredStudents[index];
          return _buildStudentCard(student);
        },
      ),
    );
  }
  
  Widget _buildStudentCard(Student student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showStudentDetail(student),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  UserAvatar(
                    name: student.name,
                    radius: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${student.grade} ${student.className}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${student.averageScore.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(student.averageScore),
                        ),
                      ),
                      Text(
                        '平均分',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '作业完成率',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '${student.completionRate.toStringAsFixed(0)}%',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getCompletionRateColor(student.completionRate),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: student.completionRate / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getCompletionRateColor(student.completionRate),
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '作业进度',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${student.completedHomework}/${student.totalHomework}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMyChildren(dynamic user) {
    // 模拟数据 - 实际应根据用户 ID 过滤
    final studentState = ref.watch(studentListProvider);
    final myChildren = studentState.students.take(2).toList();
    
    if (myChildren.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.family_restroom,
        title: '暂无孩子',
        subtitle: '添加孩子信息后在这里查看',
        action: ElevatedButton.icon(
          onPressed: null,
          icon: Icon(Icons.add),
          label: Text('添加孩子'),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: myChildren.length,
      itemBuilder: (context, index) {
        return _buildStudentCard(myChildren[index]);
      },
    );
  }
  
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索学生'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: '输入学生姓名或班级',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: const Text('清除'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
  
  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加学生'),
        content: const Text('功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
  
  void _showStudentDetail(Student student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 8,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      UserAvatar(
                        name: student.name,
                        radius: 50,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        student.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.primaryColor),
                        ),
                        child: Text(
                          '${student.grade} ${student.className}',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildStatRow('平均分数', '${student.averageScore.toStringAsFixed(1)}', Icons.grade),
                _buildStatRow('完成作业', '${student.completedHomework}/${student.totalHomework}', Icons.assignment),
                _buildStatRow('完成率', '${student.completionRate.toStringAsFixed(1)}%', Icons.trending_up),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('功能开发中...')),
                      );
                    },
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('查看详细报告'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getScoreColor(double score) {
    if (score >= 90) return AppTheme.successColor;
    if (score >= 80) return AppTheme.primaryColor;
    if (score >= 70) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
  
  Color _getCompletionRateColor(double rate) {
    if (rate >= 90) return AppTheme.successColor;
    if (rate >= 70) return AppTheme.primaryColor;
    if (rate >= 50) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}
