import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/sync_provider.dart';

class SyncStatusWidget extends StatelessWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, _) {
        final isSyncing = syncProvider.isSyncing;
        final total = syncProvider.totalUnsynced;
        final errorMessage = syncProvider.errorMessage;

        // 没有未同步数据且不在同步中
        if (total == 0 && !isSyncing && errorMessage == null) {
          return const SizedBox.shrink();
        }

        // 显示错误
        if (errorMessage != null) {
          return Card(
            margin: const EdgeInsets.all(16),
            color: Colors.red[50],
            child: ListTile(
              leading: Icon(Icons.error, color: Colors.red[700]),
              title: const Text('同步失败'),
              subtitle: Text(errorMessage),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: syncProvider.clearError,
              ),
            ),
          );
        }

        // 同步中或有未同步数据
        return Card(
          margin: const EdgeInsets.all(16),
          color: isSyncing ? Colors.blue[50] : Colors.orange[50],
          child: ListTile(
            leading: isSyncing
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.blue[700],
                    ),
                  )
                : Icon(Icons.cloud_upload, color: Colors.orange[700]),
            title: Text(
              isSyncing ? '正在同步数据...' : '有 $total 条数据待同步',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: isSyncing
                ? const Text('请保持网络连接')
                : const Text('连接网络后将自动同步'),
            trailing: isSyncing
                ? null
                : FutureBuilder<bool>(
                    future: syncProvider.hasNetwork(),
                    builder: (context, snapshot) {
                      final hasNet = snapshot.data ?? false;
                      return TextButton.icon(
                        onPressed: hasNet
                            ? () => syncProvider.manualSync()
                            : null,
                        icon: const Icon(Icons.sync, size: 18),
                        label: Text(hasNet ? '立即同步' : '无网络'),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
