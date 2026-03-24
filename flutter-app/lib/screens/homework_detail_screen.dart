import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/homework_provider.dart';
import '../providers/auth_provider.dart';
import '../models/homework_model.dart';
import '../widgets/common_widgets.dart';
import '../config/theme_config.dart';

/// 作业详情页面
/// 显示作业的完整信息，支持编辑和提交
class HomeworkDetailScreen extends ConsumerStatefulWidget {
  final int homeworkId;
  
  const HomeworkDetailScreen({
    super.key,
    required this.homeworkId,
  });

  @override
  ConsumerState<HomeworkDetailScreen> createState() => _HomeworkDetailScreenState();
}

class _HomeworkDetailScreenState extends ConsumerState<HomeworkDetailScreen> {
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String _selectedSubject = '';
  late DateTime _selectedDeadline;
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  void _initializeData() {
    final homeworkState = ref.read(homeworkProvider);
    final homework = homeworkState.homeworkList.firstWhere(
      (h) => h.id == widget.homeworkId,
      orElse: () => Homework(
        id: 0,
        title: '',
        description: '',
        subject: '',
        deadline: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    );
    
    _titleController = TextEditingController(text: homework.title);
    _descriptionController = TextEditingController(text: homework.description);
    _selectedSubject = homework.subject;
    _selectedDeadline = homework.deadline;
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final homeworkState = ref.watch(homeworkProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    final homework = homeworkState.homeworkList.firstWhere(
      (h) => h.id == widget.homeworkId,
      orElse: () => Homework(
        id: 0,
        title: '',
        description: '',
        subject: '',
        deadline: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    );
    
    if (homework.id == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('作业详情')),
        body: const EmptyStateWidget(
          icon: Icons.error_outline,
          title: '作业不存在',
          subtitle: '该作业可能已被删除',
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑作业' : '作业详情'),
        actions: [
          if (user?.role == 'teacher') ...[
            IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit),
              onPressed: () {
                if (_isEditing) {
                  _saveChanges();
                } else {
                  setState(() {
                    _isEditing = true;
                  });
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(),
            ),
          ],
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
              // 状态卡片
              _buildStatusCard(homework),
              const SizedBox(height: 16),
              
              // 作业信息
              _buildInfoCard(homework, user),
              const SizedBox(height: 16),
              
              // 作业描述
              _buildDescriptionCard(homework),
              const SizedBox(height: 16),
              
              // 提交区域 (学生可见)
              if (user?.role == 'student') ...[
                _buildSubmissionSection(homework),
                const SizedBox(height: 16),
              ],
              
              // 批改信息 (老师可见)
              if (user?.role == 'teacher' && homework.isCompleted) ...[
                _buildGradingSection(homework),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: user?.role == 'student' && !homework.isCompleted
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _submitHomework(homework),
                  icon: const Icon(Icons.send),
                  label: const Text('提交作业'),
                ),
              ),
            )
          : null,
    );
  }
  
  Widget _buildStatusCard(Homework homework) {
    final isUrgent = DateUtils.isUrgent(homework.deadline);
    final isOverdue = DateUtils.isOverdue(homework.deadline);
    
    return Card(
      color: homework.isCompleted
          ? AppTheme.successColor.withOpacity(0.1)
          : isOverdue
              ? AppTheme.errorColor.withOpacity(0.1)
              : isUrgent
                  ? AppTheme.warningColor.withOpacity(0.1)
                  : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.getSubjectColor(homework.subject),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                homework.isCompleted
                    ? Icons.check_circle
                    : isOverdue
                        ? Icons.error
                        : Icons.assignment,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    homework.isCompleted
                        ? '已完成'
                        : isOverdue
                            ? '已过期'
                            : isUrgent
                                ? '即将截止'
                                : '未完成',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: homework.isCompleted
                          ? AppTheme.successColor
                          : isOverdue
                              ? AppTheme.errorColor
                              : isUrgent
                                  ? AppTheme.warningColor
                                  : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '截止日期：${DateUtils.formatDate(homework.deadline)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Checkbox(
              value: homework.isCompleted,
              onChanged: (value) {
                ref.read(homeworkProvider.notifier).updateHomework(
                  homework.id,
                  isCompleted: value ?? false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoCard(Homework homework, dynamic user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEditableField(
              label: '作业标题',
              value: homework.title,
              controller: _titleController,
              isEditing: _isEditing,
              onSave: () {
                ref.read(homeworkProvider.notifier).updateHomework(
                  homework.id,
                  title: _titleController.text,
                );
              },
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.book, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text('科目：', style: Theme.of(context).textTheme.bodyMedium),
                if (_isEditing)
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedSubject,
                      isExpanded: true,
                      items: AppTheme.subjectColors.keys.map((subject) {
                        return DropdownMenuItem(
                          value: subject,
                          child: Text(subject),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSubject = value!;
                        });
                      },
                    ),
                  )
                else
                  SubjectChip(subject: homework.subject),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text('截止日期：', style: Theme.of(context).textTheme.bodyMedium),
                if (_isEditing)
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDeadline,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDeadline = date;
                        });
                      }
                    },
                    child: Text(DateUtils.formatDate(_selectedDeadline)),
                  )
                else
                  Text(
                    DateUtils.formatDate(homework.deadline),
                    style: TextStyle(
                      color: DateUtils.isUrgent(homework.deadline)
                          ? Colors.red
                          : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text('创建时间：', style: Theme.of(context).textTheme.bodyMedium),
                Text(DateUtils.formatDate(homework.createdAt)),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEditableField({
    required String label,
    required String value,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onSave,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.title, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: isEditing
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: label,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => onSave(),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
  
  Widget _buildDescriptionCard(Homework homework) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '作业描述',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isEditing)
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '作业描述',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
              )
            else
              Text(
                homework.description.isEmpty
                    ? '暂无描述'
                    : homework.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (_isEditing) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _initializeData();
                      });
                    },
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(homeworkProvider.notifier).updateHomework(
                        homework.id,
                        description: _descriptionController.text,
                        subject: _selectedSubject,
                        deadline: _selectedDeadline,
                      );
                      setState(() {
                        _isEditing = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('作业已更新')),
                      );
                    },
                    child: const Text('保存'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSubmissionSection(Homework homework) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.upload_file, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '提交作业',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.blue),
              title: const Text('上传图片'),
              subtitle: const Text('支持 JPG、PNG 格式'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('功能开发中...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.green),
              title: const Text('上传文档'),
              subtitle: const Text('支持 PDF、Word 格式'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('功能开发中...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGradingSection(Homework homework) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.grade, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '批改信息',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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
                        '得分',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '-- / 100',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '批改时间',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateUtils.formatDateTime(homework.updatedAt ?? homework.createdAt),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('功能开发中...')),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('填写评语'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _saveChanges() {
    ref.read(homeworkProvider.notifier).updateHomework(
      homeworkId,
      title: _titleController.text,
      description: _descriptionController.text,
      subject: _selectedSubject,
      deadline: _selectedDeadline,
    );
    
    setState(() {
      _isEditing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('作业已更新')),
    );
  }
  
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个作业吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(homeworkProvider.notifier).deleteHomework(homeworkId);
              Navigator.pop(context);
              if (context.mounted) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('作业已删除')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
  
  void _submitHomework(Homework homework) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提交作业'),
        content: const Text('确定要提交这个作业吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(homeworkProvider.notifier).updateHomework(
                homework.id,
                isCompleted: true,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('作业已提交')),
              );
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }
}
