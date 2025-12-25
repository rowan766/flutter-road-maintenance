import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import '../../inspection/domain/models/road_defect.dart';
import '../../maintenance/domain/models/maintenance_task.dart';
import '../../../core/config/app_config.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final Dio _dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
  final Connectivity _connectivity = Connectivity();
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _syncTimer;
  
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  // 初始化同步服务
  Future<void> initialize() async {
    // 监听网络状态变化
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (results.isNotEmpty && results.first != ConnectivityResult.none) {
          // 网络恢复时立即同步
          syncAllData();
        }
      },
    );

    // 定时同步（每5分钟）
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      syncAllData();
    });

    // 启动时尝试同步
    await syncAllData();
  }

  // 检查网络连接
  Future<bool> hasNetwork() async {
    final results = await _connectivity.checkConnectivity();
    return results.isNotEmpty && results.first != ConnectivityResult.none;
  }

  // 同步所有数据
  Future<void> syncAllData() async {
    if (_isSyncing) return;
    
    final hasNet = await hasNetwork();
    if (!hasNet) return;

    _isSyncing = true;

    try {
      // 同步病害记录
      await _syncDefects();
      
      // 同步任务数据
      await _syncTasks();
      
      // 下载服务器更新
      await _downloadUpdates();
      
      print('✅ 数据同步完成');
    } catch (e) {
      print('❌ 同步失败: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // 同步病害记录
  Future<void> _syncDefects() async {
    final box = Hive.box<RoadDefect>('defects');
    final unsyncedDefects = box.values.where((d) => !d.synced).toList();

    for (var defect in unsyncedDefects) {
      try {
        // 上传病害数据
        final response = await _dio.post(
          '/api/defects',
          data: defect.toJson(),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // 标记为已同步
          final index = box.values.toList().indexWhere((d) => d.id == defect.id);
          if (index != -1) {
            await box.putAt(index, defect.copyWith(synced: true));
          }
          print('✅ 病害记录已同步: ${defect.id}');
        }
      } catch (e) {
        print('❌ 病害记录同步失败: ${defect.id}, 错误: $e');
      }
    }
  }

  // 同步任务数据
  Future<void> _syncTasks() async {
    final box = Hive.box<MaintenanceTask>('tasks');
    
    // 这里可以实现任务的上传逻辑
    // 例如：上传本地创建的任务、更新状态变化等
    
    try {
      final tasks = box.values.toList();
      final tasksJson = tasks.map((t) => t.toJson()).toList();
      
      await _dio.post(
        '/api/tasks/sync',
        data: {'tasks': tasksJson},
      );
      
      print('✅ 任务数据已同步');
    } catch (e) {
      print('❌ 任务同步失败: $e');
    }
  }

  // 下载服务器更新
  Future<void> _downloadUpdates() async {
    try {
      // 获取服务器上的新任务
      final response = await _dio.get('/api/tasks/updates');
      
      if (response.statusCode == 200) {
        final tasksData = response.data['tasks'] as List;
        final box = Hive.box<MaintenanceTask>('tasks');
        
        for (var taskJson in tasksData) {
          // 检查本地是否已存在
          final exists = box.values.any((t) => t.id == taskJson['id']);
          
          if (!exists) {
            // 添加新任务
            final task = _parseTask(taskJson);
            await box.add(task);
            print('✅ 下载新任务: ${task.id}');
          }
        }
      }
    } catch (e) {
      print('❌ 下载更新失败: $e');
    }
  }

  // 解析任务数据（示例）
  MaintenanceTask _parseTask(Map<String, dynamic> json) {
    return MaintenanceTask(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      roadName: json['roadName'],
      taskType: json['taskType'],
      status: json['status'],
      priority: json['priority'],
      createdAt: DateTime.parse(json['createdAt']),
      assignee: json['assignee'],
      startTime: json['startTime'] != null 
          ? DateTime.parse(json['startTime']) 
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      photos: json['photos'] != null 
          ? List<String>.from(json['photos']) 
          : null,
      remarks: json['remarks'],
    );
  }

  // 手动触发同步
  Future<void> manualSync() async {
    await syncAllData();
  }

  // 获取未同步数据数量
  Future<Map<String, int>> getUnsyncedCount() async {
    final defectBox = Hive.box<RoadDefect>('defects');
    final unsyncedDefects = defectBox.values.where((d) => !d.synced).length;

    return {
      'defects': unsyncedDefects,
      'total': unsyncedDefects,
    };
  }

  // 清理
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }
}
