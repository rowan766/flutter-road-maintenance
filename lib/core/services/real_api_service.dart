import 'package:dio/dio.dart';
import '../../features/inspection/domain/models/road_defect.dart';
import '../../features/maintenance/domain/models/maintenance_task.dart';

/// 真实API服务 - 连接实际后端
/// 后端完成后启用此服务
class RealApiService {
  final Dio _dio;
  
  RealApiService(this._dio);

  /// 登录
  Future<Response> login(String username, String password) async {
    return await _dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });
  }

  /// 登出
  Future<Response> logout() async {
    return await _dio.post('/auth/logout');
  }

  /// 上传病害记录
  Future<Response> uploadDefect(RoadDefect defect) async {
    return await _dio.post('/defects', data: defect.toJson());
  }

  /// 批量上传病害
  Future<Response> uploadDefectsBatch(List<RoadDefect> defects) async {
    return await _dio.post('/defects/batch', data: {
      'defects': defects.map((d) => d.toJson()).toList(),
    });
  }

  /// 获取病害列表
  Future<Response> getDefects({
    int page = 1,
    int pageSize = 20,
    String? type,
    String? severity,
  }) async {
    return await _dio.get('/defects', queryParameters: {
      'page': page,
      'pageSize': pageSize,
      if (type != null) 'type': type,
      if (severity != null) 'severity': severity,
    });
  }

  /// 同步任务数据
  Future<Response> syncTasks(List<MaintenanceTask> tasks) async {
    return await _dio.post('/tasks/sync', data: {
      'tasks': tasks.map((t) => t.toJson()).toList(),
    });
  }

  /// 获取任务更新
  Future<Response> getTaskUpdates({String? lastSyncTime}) async {
    return await _dio.get('/tasks/updates', queryParameters: {
      if (lastSyncTime != null) 'lastSyncTime': lastSyncTime,
    });
  }

  /// 创建任务
  Future<Response> createTask(MaintenanceTask task) async {
    return await _dio.post('/tasks', data: {
      'title': task.title,
      'description': task.description,
      'roadName': task.roadName,
      'taskType': task.taskType,
      'priority': task.priority,
    });
  }

  /// 更新任务状态
  Future<Response> updateTaskStatus(
    String taskId,
    String status, {
    String? assignee,
  }) async {
    return await _dio.put('/tasks/$taskId/status', data: {
      'status': status,
      if (assignee != null) 'assignee': assignee,
    });
  }

  /// 上传照片
  Future<Response> uploadPhoto(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    
    return await _dio.post('/upload/photo', data: formData);
  }

  /// 批量上传照片
  Future<Response> uploadPhotos(List<String> filePaths) async {
    final files = await Future.wait(
      filePaths.map((path) => MultipartFile.fromFile(path)),
    );
    
    final formData = FormData.fromMap({
      'files': files,
    });
    
    return await _dio.post('/upload/photos', data: formData);
  }

  /// 获取概览数据
  Future<Response> getOverview() async {
    return await _dio.get('/reports/overview');
  }

  /// 病害类型统计
  Future<Response> getDefectTypeStats() async {
    return await _dio.get('/reports/defects/types');
  }
}
