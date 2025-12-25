import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../inspection/domain/models/road_defect.dart';
import '../../maintenance/domain/models/maintenance_task.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('统计报表')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _OverviewCard(),
          const SizedBox(height: 16),
          _DefectTypeChart(),
          const SizedBox(height: 16),
          _TaskStatusChart(),
          const SizedBox(height: 16),
          _RecentActivityList(),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<RoadDefect>('defects').listenable(),
      builder: (context, Box<RoadDefect> defectBox, _) {
        return ValueListenableBuilder(
          valueListenable: Hive.box<MaintenanceTask>('tasks').listenable(),
          builder: (context, Box<MaintenanceTask> taskBox, _) {
            final defectCount = defectBox.length;
            final taskCount = taskBox.length;
            final completedTasks = taskBox.values
                .where((t) => t.status == '已完成' || t.status == '已验收')
                .length;
            final inProgressTasks =
                taskBox.values.where((t) => t.status == '进行中').length;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '数据概览',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            label: '病害记录',
                            value: defectCount.toString(),
                            color: Colors.red,
                          ),
                        ),
                        Expanded(
                          child: _StatItem(
                            label: '总任务数',
                            value: taskCount.toString(),
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            label: '进行中',
                            value: inProgressTasks.toString(),
                            color: Colors.orange,
                          ),
                        ),
                        Expanded(
                          child: _StatItem(
                            label: '已完成',
                            value: completedTasks.toString(),
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _DefectTypeChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<RoadDefect>('defects').listenable(),
      builder: (context, Box<RoadDefect> box, _) {
        final defects = box.values.toList();
        final typeCount = <String, int>{};
        
        for (var defect in defects) {
          typeCount[defect.type] = (typeCount[defect.type] ?? 0) + 1;
        }

        if (typeCount.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('暂无病害数据')),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '病害类型分布',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...typeCount.entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(width: 80, child: Text(e.key)),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: e.value / defects.length,
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${e.value}'),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TaskStatusChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<MaintenanceTask>('tasks').listenable(),
      builder: (context, Box<MaintenanceTask> box, _) {
        final tasks = box.values.toList();
        final statusCount = <String, int>{};
        
        for (var task in tasks) {
          statusCount[task.status] = (statusCount[task.status] ?? 0) + 1;
        }

        if (statusCount.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('暂无任务数据')),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '任务状态分布',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...statusCount.entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(width: 80, child: Text(e.key)),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: e.value / tasks.length,
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${e.value}'),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '最近活动',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ValueListenableBuilder(
              valueListenable: Hive.box<MaintenanceTask>('tasks').listenable(),
              builder: (context, Box<MaintenanceTask> box, _) {
                final tasks = box.values.toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                final recentTasks = tasks.take(5).toList();

                if (recentTasks.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('暂无活动'),
                    ),
                  );
                }

                return Column(
                  children: recentTasks.map((task) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(task.title),
                      subtitle: Text(task.roadName),
                      trailing: Text(
                        task.status,
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
