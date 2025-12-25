import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/maintenance_task.dart';

class TaskDetailPage extends StatelessWidget {
  final MaintenanceTask task;
  const TaskDetailPage({super.key, required this.task});

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    final box = Hive.box<MaintenanceTask>('tasks');
    final index = box.values.toList().indexWhere((t) => t.id == task.id);
    
    if (index != -1) {
      final updatedTask = task.copyWith(
        status: newStatus,
        startTime: newStatus == '进行中' ? DateTime.now() : task.startTime,
        completedAt: newStatus == '已完成' ? DateTime.now() : task.completedAt,
      );
      await box.putAt(index, updatedTask);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('状态已更新为：$newStatus')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('任务详情'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (status) => _updateStatus(context, status),
            itemBuilder: (context) => [
              const PopupMenuItem(value: '待分配', child: Text('待分配')),
              const PopupMenuItem(value: '进行中', child: Text('进行中')),
              const PopupMenuItem(value: '已完成', child: Text('已完成')),
              const PopupMenuItem(value: '已验收', child: Text('已验收')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoCard(
            title: '基本信息',
            children: [
              _InfoRow('任务标题', task.title),
              _InfoRow('任务类型', task.taskType),
              _InfoRow('优先级', task.priority),
              _InfoRow('当前状态', task.status),
              _InfoRow('道路名称', task.roadName),
            ],
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: '任务描述',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(task.description),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: '时间信息',
            children: [
              _InfoRow(
                '创建时间',
                _formatDateTime(task.createdAt),
              ),
              if (task.startTime != null)
                _InfoRow(
                  '开始时间',
                  _formatDateTime(task.startTime!),
                ),
              if (task.completedAt != null)
                _InfoRow(
                  '完成时间',
                  _formatDateTime(task.completedAt!),
                ),
            ],
          ),
          if (task.assignee != null) ...[
            const SizedBox(height: 16),
            _InfoCard(
              title: '负责人',
              children: [
                _InfoRow('姓名', task.assignee!),
              ],
            ),
          ],
          if (task.latitude != null && task.longitude != null) ...[
            const SizedBox(height: 16),
            _InfoCard(
              title: '位置信息',
              children: [
                _InfoRow(
                  '坐标',
                  '${task.latitude!.toStringAsFixed(6)}, '
                      '${task.longitude!.toStringAsFixed(6)}',
                ),
              ],
            ),
          ],
          if (task.remarks != null) ...[
            const SizedBox(height: 16),
            _InfoCard(
              title: '备注',
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(task.remarks!),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
