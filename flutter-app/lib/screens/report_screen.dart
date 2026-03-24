import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/homework_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/common_widgets.dart';
import '../config/theme_config.dart';

/// 学习报告数据
class ReportData {
  final int totalHomework;
  final int completedHomework;
  final int pendingHomework;
  final double averageScore;
  final Map<String, int> subjectDistribution;
  final List<WeeklyData> weeklyData;
  
  ReportData({
    required this.totalHomework,
    required this.completedHomework,
    required this.pendingHomework,
    required this.averageScore,
    required this.subjectDistribution,
    required this.weeklyData,
  });
  
  double get completionRate {
    if (totalHomework == 0) return 0;
    return completedHomework / totalHomework * 100;
  }
}

class WeeklyData {
  final String week;
  final int completed;
  final int total;
  final double averageScore;
  
  WeeklyData({
    required this.week,
    required this.completed,
    required this.total,
    required this.averageScore,
  });
}

/// 学习报告提供者
final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier(ref);
});

class ReportState {
  final bool isLoading;
  final ReportData? reportData;
  final String? error;
  final String period; // 'weekly' or 'monthly'
  
  ReportState({
    this.isLoading = false,
    this.reportData,
    this.error,
    this.period = 'weekly',
  });
  
  ReportState copyWith({
    bool? isLoading,
    ReportData? reportData,
    String? error,
    String? period,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      reportData: reportData ?? this.reportData,
      error: error ?? this.error,
      period: period ?? this.period,
    );
  }
}

class ReportNotifier extends StateNotifier<ReportState> {
  final Ref ref;
  
  ReportNotifier(this.ref) : super(ReportState()) {
    loadReport();
  }
  
  Future<void> loadReport() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final homeworkState = ref.read(homeworkProvider);
      final homeworkList = homeworkState.homeworkList;
      
      // 计算统计数据
      final totalHomework = homeworkList.length;
      final completedHomework = homeworkState.getCompletedHomework().length;
      final pendingHomework = homeworkState.getPendingHomework().length;
      
      // 科目分布
      final subjectDistribution = <String, int>{};
      for (final homework in homeworkList) {
        subjectDistribution[homework.subject] = 
          (subjectDistribution[homework.subject] ?? 0) + 1;
      }
      
      // 模拟周数据
      final weeklyData = [
        WeeklyData(week: '第 1 周', completed: 5, total: 6, averageScore: 88),
        WeeklyData(week: '第 2 周', completed: 7, total: 7, averageScore: 92),
        WeeklyData(week: '第 3 周', completed: 6, total: 8, averageScore: 85),
        WeeklyData(week: '第 4 周', completed: 4, total: 5, averageScore: 90),
      ];
      
      state = state.copyWith(
        isLoading: false,
        reportData: ReportData(
          totalHomework: totalHomework,
          completedHomework: completedHomework,
          pendingHomework: pendingHomework,
          averageScore: 89.5,
          subjectDistribution: subjectDistribution,
          weeklyData: weeklyData,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  void setPeriod(String period) {
    state = state.copyWith(period: period);
    loadReport();
  }
}

/// 学习报告页面
/// 显示学习统计、周报、月报等
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习报告'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '概览'),
            Tab(text: '周报'),
            Tab(text: '月报'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(reportProvider.notifier).loadReport();
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中...')),
              );
            },
          ),
        ],
      ),
      body: reportState.isLoading
          ? const LoadingWidget(message: '加载报告中...')
          : reportState.reportData == null
              ? const EmptyStateWidget(
                  icon: Icons.assessment_outlined,
                  title: '暂无数据',
                  subtitle: '完成作业后查看学习报告',
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(reportState.reportData!),
                    _buildWeeklyTab(reportState.reportData!),
                    _buildMonthlyTab(reportState.reportData!),
                  ],
                ),
    );
  }
  
  Widget _buildOverviewTab(ReportData data) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(reportProvider.notifier).loadReport();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 总体统计
            Text(
              '学习概览',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                StatCard(
                  icon: Icons.assignment,
                  label: '总作业数',
                  value: data.totalHomework.toString(),
                  color: AppTheme.primaryColor,
                ),
                StatCard(
                  icon: Icons.check_circle,
                  label: '已完成',
                  value: data.completedHomework.toString(),
                  color: AppTheme.successColor,
                ),
                StatCard(
                  icon: Icons.pending_actions,
                  label: '待完成',
                  value: data.pendingHomework.toString(),
                  color: AppTheme.warningColor,
                ),
                StatCard(
                  icon: Icons.grade,
                  label: '平均分',
                  value: data.averageScore.toStringAsFixed(1),
                  color: AppTheme.accentColor,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 完成率
            Text(
              '作业完成率',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '完成率',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${data.completionRate.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getCompletionRateColor(data.completionRate),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: data.completionRate / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getCompletionRateColor(data.completionRate),
                        ),
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '已完成 ${data.completedHomework} 个',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '剩余 ${data.pendingHomework} 个',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 科目分布
            Text(
              '科目分布',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: data.subjectDistribution.entries.map((entry) {
                    final percentage = data.totalHomework > 0
                        ? entry.value / data.totalHomework * 100
                        : 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text(
                              entry.key,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.getSubjectColor(entry.key),
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 40,
                            child: Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 学习建议
            Text(
              '学习建议',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSuggestionCard(
              icon: Icons.lightbulb,
              title: '继续保持',
              content: '你的作业完成率很高，继续保持这个好习惯！',
              color: AppTheme.successColor,
            ),
            const SizedBox(height: 12),
            _buildSuggestionCard(
              icon: Icons.trending_up,
              title: '提升建议',
              content: '可以尝试提前完成作业，避免临近截止日期时压力过大。',
              color: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeeklyTab(ReportData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '每周学习情况',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...data.weeklyData.map((weekData) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          weekData.week,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getScoreColor(weekData.averageScore).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _getScoreColor(weekData.averageScore),
                            ),
                          ),
                          child: Text(
                            '平均分：${weekData.averageScore.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: _getScoreColor(weekData.averageScore),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
                              Text(
                                '完成进度',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${weekData.completed}/${weekData.total}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: weekData.total > 0 
                                  ? weekData.completed / weekData.total 
                                  : 0,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  
  Widget _buildMonthlyTab(ReportData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '月度总结',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildMonthStatRow('总作业数', data.totalHomework.toString(), Icons.assignment),
                  const Divider(height: 24),
                  _buildMonthStatRow('完成作业', data.completedHomework.toString(), Icons.check_circle),
                  const Divider(height: 24),
                  _buildMonthStatRow('平均分数', data.averageScore.toStringAsFixed(1), Icons.grade),
                  const Divider(height: 24),
                  _buildMonthStatRow('完成率', '${data.completionRate.toStringAsFixed(1)}%', Icons.trending_up),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '学科表现',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: data.subjectDistribution.entries.map((entry) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.getSubjectColor(entry.key),
                      child: Text(
                        entry.key.substring(0, 1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(entry.key),
                    trailing: Text(
                      '${entry.value}个作业',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('功能开发中...')),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('导出报告'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuggestionCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMonthStatRow(String label, String value, IconData icon) {
    return Row(
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
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Color _getCompletionRateColor(double rate) {
    if (rate >= 90) return AppTheme.successColor;
    if (rate >= 70) return AppTheme.primaryColor;
    if (rate >= 50) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
  
  Color _getScoreColor(double score) {
    if (score >= 90) return AppTheme.successColor;
    if (score >= 80) return AppTheme.primaryColor;
    if (score >= 70) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}
