import 'package:flutter/foundation.dart';
import '../services/sync_service.dart';

class SyncProvider extends ChangeNotifier {
  final SyncService _syncService = SyncService();
  
  bool _isSyncing = false;
  Map<String, int> _unsyncedCount = {};
  String? _lastSyncTime;
  String? _errorMessage;

  bool get isSyncing => _isSyncing;
  Map<String, int> get unsyncedCount => _unsyncedCount;
  String? get lastSyncTime => _lastSyncTime;
  String? get errorMessage => _errorMessage;
  int get totalUnsynced => _unsyncedCount['total'] ?? 0;

  Future<void> initialize() async {
    await _syncService.initialize();
    await refreshUnsyncedCount();
    
    // 监听同步状态变化
    _startStatusMonitoring();
  }

  void _startStatusMonitoring() {
    // 每10秒检查一次未同步数量
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 10));
      if (!_isSyncing) {
        await refreshUnsyncedCount();
      }
      return true;
    });
  }

  Future<void> refreshUnsyncedCount() async {
    try {
      _unsyncedCount = await _syncService.getUnsyncedCount();
      notifyListeners();
    } catch (e) {
      print('获取未同步数量失败: $e');
    }
  }

  Future<void> manualSync() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _syncService.manualSync();
      _lastSyncTime = DateTime.now().toString();
      await refreshUnsyncedCount();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<bool> hasNetwork() async {
    return await _syncService.hasNetwork();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
