import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/maintenance_task.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _roadNameController = TextEditingController();

  String _taskType = '日常养护';
  String _priority = '中';

  final List<String> _taskTypes = ['日常养护', '专项维修', '应急抢修'];
  final List<String> _priorities = ['低', '中', '高', '紧急'];

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    final task = MaintenanceTask(
      id: const Uuid().v4(),
      title: _titleController.text,
      description: _descController.text,
      roadName: _roadNameController.text,
      taskType: _taskType,
      status: '待分配',
      priority: _priority,
      createdAt: DateTime.now(),
    );

    final box = await Hive.openBox<MaintenanceTask>('tasks');
    await box.add(task);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('任务创建成功')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建任务'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _createTask,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '任务标题',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty == true ? '请输入标题' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _taskType,
              decoration: const InputDecoration(
                labelText: '任务类型',
                border: OutlineInputBorder(),
              ),
              items: _taskTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) => setState(() => _taskType = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: '优先级',
                border: OutlineInputBorder(),
              ),
              items: _priorities.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority),
                );
              }).toList(),
              onChanged: (value) => setState(() => _priority = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _roadNameController,
              decoration: const InputDecoration(
                labelText: '道路名称',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty == true ? '请输入道路名称' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: '任务描述',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty == true ? '请输入任务描述' : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _roadNameController.dispose();
    super.dispose();
  }
}
