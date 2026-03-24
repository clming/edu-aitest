import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../providers/homework_provider.dart';
import '../widgets/common_widgets.dart';
import '../config/theme_config.dart';
import 'homework_list_screen.dart';
import 'student_list_screen.dart';
import 'profile_screen.dart';
import 'report_screen.dart';

/// 首页
/// 
/// 包含底部导航栏，支持切换：
/// - 仪表盘 (首页)
/// - 作业
/// - 学生
/// - 报告
/// - 我的
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const HomeworkListScreen(),
    const StudentListScreen(),
    const ReportScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // 加载作业数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeworkProvider.notifier).loadHomework();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: '作业',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: '学生',
          ),
          NavigationDestination(
            icon: Icon(Icons.assessment_outlined),
            selectedIcon: Icon(Icons.assessment),
            label: '报告',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

/// 仪表盘屏幕
/// 
/// 显示学习概览、统计数据、待完成作业等
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final homeworkState = ref.watch(homeworkProvider);
    final user = authState.user;
    final pendingHomework = homeworkState.getPendingHomework();

    return Scaffold(
      appBar: AppBar(
        title: const Text('教育助手'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('暂无新通知')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(homeworkProvider.notifier).loadHomework();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 欢迎卡片
              _buildWelcomeCard(context, user),
              const SizedBox(height: 24),

              // 统计卡片
              Text(
                '学习概览',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
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
                    value: homeworkState.homeworkList.length.toString(),
                    color: AppTheme.primaryColor,
                    onTap: () {
                      // 切换到作业标签
                    },
                  ),
                  StatCard(
                    icon: Icons.pending_actions,
                    label: '待完成',
                    value: pendingHomework.length.toString(),
                    color: AppTheme.warningColor,
                    onTap: () {
                      // 切换到作业标签
                    },
                  ),
                  StatCard(
                    icon: Icons.check_circle,
                    label: '已完成',
                    value: homeworkState.getCompletedHomework().length.toString(),
                    color: AppTheme.successColor,
                    onTap: () {
                      // 切换到作业标签
                    },
                  ),
                  StatCard(
                    icon: Icons.book,
                    label: '科目数',
                    value: homeworkState.homeworkList
                        .map((h) => h.subject)
                        .toSet()
                        .length
                        .toString(),
                    color: AppTheme.accentColor,
                    onTap: () {
                      // 查看科目分布
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 快捷操作
              Text(
                '快捷操作',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildQuickActions(context, user),
              const SizedBox(height: 24),

              // 待完成作业
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '待完成作业',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // 切换到作业标签 (索引 1)
                    },
                    child: const Text('查看全部'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              if (homeworkState.isLoading)
                const LoadingWidget()
              else if (pendingHomework.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.celebration,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '太棒了！所有作业都已完成',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '继续保持，你是最棒的！🎉',
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...pendingHomework.take(5).map((homework) {
                  return _buildHomeworkCard(context, homework);
                }),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildWelcomeCard(BuildContext context, dynamic user) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    
    if (hour < 6) {
      greeting = '夜深了，早点休息吧';
    } else if (hour < 12) {
      greeting = '早上好';
    } else if (hour < 14) {
      greeting = '中午好';
    } else if (hour < 18) {
      greeting = '下午好';
    } else {
      greeting = '晚上好';
    }
    
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting，${user?.username ?? "用户"}！',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '今天是学习的好日子，继续加油！💪',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.getRoleColor(user?.role),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      AppTheme.getRoleName(user?.role),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.school,
                size: 48,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActions(BuildContext context, dynamic user) {
    final actions = [
      _QuickActionItem(
        icon: Icons.add_circle_outline,
        label: '添加作业',
        color: AppTheme.primaryColor,
        visible: user?.role == 'teacher',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('功能开发中...')),
          );
        },
      ),
      _QuickActionItem(
        icon: Icons.people_outline,
        label: '学生管理',
        color: AppTheme.successColor,
        visible: user?.role == 'teacher' || user?.role == 'parent',
        onTap: () {
          context.go('/home/students');
        },
      ),
      _QuickActionItem(
        icon: Icons.assessment,
        label: '学习报告',
        color: AppTheme.accentColor,
        visible: true,
        onTap: () {
          context.go('/home/report');
        },
      ),
      _QuickActionItem(
        icon: Icons.settings,
        label: '设置',
        color: AppTheme.primaryColor,
        visible: true,
        onTap: () {
          // 跳转到设置页面
        },
      ),
    ];
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.8,
      children: actions.where((action) => action.visible).map((action) {
        return _buildQuickActionItem(context, action);
      }).toList(),
    );
  }
  
  Widget _buildQuickActionItem(BuildContext context, _QuickActionItem action) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              action.icon,
              color: action.color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            action.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildHomeworkCard(BuildContext context, dynamic homework) {
    final isUrgent = DateUtils.isUrgent(homework.deadline);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.go('/home/homework/${homework.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.getSubjectColor(homework.subject),
                    child: Text(
                      homework.subject.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          homework.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          homework.subject,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.warningColor),
                      ),
                      child: const Text(
                        '紧急',
                        style: TextStyle(
                          color: AppTheme.warningColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                homework.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: isUrgent ? Colors.red : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '截止：${DateUtils.formatDate(homework.deadline)}',
                    style: TextStyle(
                      color: isUrgent ? Colors.red : Colors.grey[600],
                      fontSize: 12,
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
}

class _QuickActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final bool visible;
  final VoidCallback onTap;
  
  _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    this.visible = true,
    required this.onTap,
  });
}
