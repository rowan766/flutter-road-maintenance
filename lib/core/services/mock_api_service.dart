import 'package:dio/dio.dart';
import '../../features/inspection/domain/models/road_defect.dart';
import '../../features/maintenance/domain/models/maintenance_task.dart';

/// Mock API服务 - 用于前端开发，模拟后端接口
/// 后端完成后，只需切换到RealApiService即可
class MockApiService {
  final Dio _dio;
  
  MockApiService(this._dio);

  // 模拟网络延迟
  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// 登录
  Future<Response> login(String username, String password) async {
    await _delay();
    
    // 模拟登录成功
    return Response(
      requestOptions: RequestOptions(path: '/auth/login'),
      statusCode: 200,
      data: {
        'code': 200,
        'message': 'success',
        'data': {
          'user': {
            'id': 'user_001',
            'username': username,
            'avatar': 'https://via.placeholder.com/150',
          },
          'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        }
      },
    );
  }

  /// 上传病害记录
  Future<Response> uploadDefect(RoadDefect defect) async {
    await _delay();
    
    return Response(
      requestOptions: RequestOptions(path: '/defects'),
      statusCode: 200,
      data: {
        'code': 200,
        'message': 'success',
        'data': {
          'id': defect.id,
          'synced': true,
          'syncedAt': DateTime.now().toIso8601String(),
        }
      },
    );
  }

  /// 批量上传病害
  Future<Response> uploadDefectsBatch(List<RoadDefect> defects) async {
    await _delay();
    
    return Response(
      requestOptions: RequestOptions(path: '/defects/batch'),
      statusCode: 200,
      data: {
        'code': 200,
        'message': 'success',
        'data': {
          'success': defects.map((d) => d.id).toList(),
          'failed': [],
        }
      },
    );
  }

  /// 同步任务数据
  Future<Response> syncTasks(List<MaintenanceTask> tasks) async {
    await _delay();
    
    return Response(
      requestOptions: RequestOptions(path: '/tasks/sync'),
      statusCode: 200,
      data: {
        'code': 200,
        'message': 'success',
        'data': {
          'syncedCount': tasks.length,
        }
      },
    );
  }

  /// 获取任务更新
  Future<Response> getTaskUpdates({String? lastSyncTime}) async {
    await _delay();
    
    // 模拟返回2条新任务
    return Response(
      requestOptions: RequestOptions(path: '/tasks/updates'),
      statusCode: 200,
      data: {
        'code': 200,
        'message': 'success',
        'data': {
          'tasks': [
            {
              'id': 'mock_task_${DateTime.now().millisecondsSinceEpoch}_1',
              'title': '道路清扫',
              'description': '主干道日常清扫',
              'roadName': '建国路',
              'taskType': '日常养护',
              'status': '待分配',
              'priority': '中',
              'createdAt': DateTime.now().toIso8601String(),
            },
            {
              'id': 'mock_task_${DateTime.now().millisecondsSinceEpoch}_2',
              'title': '修复井盖',
              'description': '人民路井盖损坏修复',
              'roadName': '人民路',
              'taskType': '应急抢修',
              'status': '待分配',
              'priority': '紧急',
              'createdAt': DateTime.now().toIso8601String(),
            }
          ]
        }
      },
    );
  }

  /// 创建任务
  Future<Response> createTask(MaintenanceTask task) async {
    await _delay();
    
    return Response(
      requestOptions: RequestOptions(path: '/tasks'),
      statusCode: 200,
      data: {
        'code': 200,
        'message': 'success',
        'data': {
          'id': task.id,
          'title': task.title,
          'status': '待分配',
          'createdAt': DateTime.now().toIso8601String(),
        }
      },
    );
  }

  /// 更新任务状态
  Future<Response> updateTaskStatus(String taskId, String status, {String? assignee}) async {
    await _delay();
    
    return Response(
      requestOptions: RequestOptions(path: '/tasks/$taskId/status'),
      statusCode: 200,
      data: {
        'code': 200,
        'message': 'success',
        'data': {
          'id': taskId,
          'status': status,
          'assignee': assignee,
          'updatedAt': DateTime.now().toIso8601String(),
        }
      },
    );
  }

  /// 上传照片
  Future<Response> uploadPhoto(String filePath) async {
    await _delay();
    
    final filename = filePath.split('/').last;
    return Response(
      requestOptions: RequestOptions(path: '/upload/photo'),
      statusCode: 200,
      data: {
        'code': 200,
        'message': 'success',
        'data': {
          'url': 'https://cdn.example.com/photos/$filename',
          'filename': filename,
          'size': 1024000,
        }
      },
    );
  }

  /// 获取概览数据
  Future<Response> getOverview() async {
    await _delay();
    
    return Response(
      requestOptions: RequestOptions(path: '/reports/overview'),
      statusCode: 200,
      data: {
        'code': 200,
        'message': 'success',
        'data': {
          'defectCount': 150,
          'taskCount': 80,
          'completedTaskCount': 60,
          'inProgressTaskCount': 15,
        }
      },
    );
  }

  /// 病害类型统计
  Future<Response> getDefectTypeStats() async {
    await _delay();
    
    return Response(
      requestOptions: RequestOptions(path: '/reports/defects/types'),
      statusCode: 200,
      data: {
        'code': 200,
        'message': 'success',
        'data': {
          '裂缝': 45,
          '坑槽': 30,
          '沉陷': 20,
          '松散': 25,
          '波浪': 15,
          '其他': 15,
        }
      },
    );
  }
}
