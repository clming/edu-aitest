import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/homework_provider.dart';
import '../models/homework_model.dart';

class HomeworkListScreen extends ConsumerWidget {
  const HomeworkListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeworkState = ref.watch(homeworkProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('作业列表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context, ref);
            },
          ),
        ],
      ),
      body: homeworkState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : homeworkState.homeworkList.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(homeworkProvider.notifier).loadHomework();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: homeworkState.homeworkList.length,
                    itemBuilder: (context, index) {
                      final homework = homeworkState.homeworkList[index];
                      return _buildHomeworkCard(context, ref, homework);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddHomeworkDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_turned_in,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无作业',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮添加新作业',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkCard(
    BuildContext context,
    WidgetRef ref,
    Homework homework,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(homework.id.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('确认删除'),
              content: const Text('确定要删除这个作业吗？'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('删除', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) {
          ref.read(homeworkProvider.notifier).deleteHomework(homework.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('作业已删除'),
              action: SnackBarAction(
                label: '撤销',
                onPressed: () {
                  // TODO: 恢复删除的作业
                },
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getSubjectColor(homework.subject),
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          homework.subject,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
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
              const SizedBox(height: 12),
              Text(
                homework.description,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: _isUrgent(homework.deadline) 
                      ? Colors.red 
                      : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '截止：${_formatDate(homework.deadline)}',
                    style: TextStyle(
                      color: _isUrgent(homework.deadline) 
                        ? Colors.red 
                        : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (homework.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '已完成',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
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

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选作业'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('全部作业'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 显示全部作业
              },
            ),
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('待完成'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 显示待完成作业
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('已完成'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 显示已完成作业
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHomeworkDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedSubject = '数学';
    DateTime selectedDeadline = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('添加作业'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: '作业标题',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '作业描述',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedSubject,
                  decoration: const InputDecoration(
                    labelText: '科目',
                    border: OutlineInputBorder(),
                  ),
                  items: ['数学', '语文', '英语', '物理', '化学', '生物']
                      .map((subject) => DropdownMenuItem(
                            value: subject,
                            child: Text(subject),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSubject = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('截止日期'),
                  subtitle: Text(_formatDate(selectedDeadline)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDeadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDeadline = date;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入作业标题')),
                  );
                  return;
                }

                await ref.read(homeworkProvider.notifier).createHomework(
                  title: titleController.text,
                  description: descriptionController.text,
                  subject: selectedSubject,
                  deadline: selectedDeadline,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('作业已添加')),
                  );
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    final colors = {
      '数学': Colors.blue,
      '语文': Colors.red,
      '英语': Colors.green,
      '物理': Colors.purple,
      '化学': Colors.orange,
      '生物': Colors.teal,
    };
    return colors[subject] ?? Colors.grey;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isUrgent(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;
    return difference <= 3;
  }
}
