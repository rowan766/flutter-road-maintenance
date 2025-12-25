import 'package:flutter/material.dart';
import '../../core/services/sync_service.dart';

class SyncStatusWidget extends StatefulWidget {
  const SyncStatusWidget({super.key});

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  final SyncService _syncService = SyncService();
  Map<String, int> _unsyncedCount = {};

  @override
  void initState() {
    super.initState();
    _loadUnsyncedCount();
  }

  Future<void> _loadUnsyncedCount() async {
    final count = await _syncService.getUnsyncedCount();
    if (mounted) {
      setState(() => _unsyncedCount = count);
    }
  }

  Future<void> _handleSync() async {
    await _syncService.manualSync();
    await _loadUnsyncedCount();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('同步完成')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _unsyncedCount['total'] ?? 0;
    final isSyncing = _syncService.isSyncing;

    if (total == 0 && !isSyncing) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.orange[50],
      child: ListTile(
        leading: isSyncing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.cloud_upload, color: Colors.orange[700]),
        title: Text(
          isSyncing ? '正在同步...' : '有 $total 条数据待同步',
        ),
        trailing: isSyncing
            ? null
            : TextButton(
                onPressed: _handleSync,
                child: const Text('立即同步'),
              ),
      ),
    );
  }
}
