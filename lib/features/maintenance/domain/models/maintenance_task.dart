import 'package:hive/hive.dart';

part 'maintenance_task.g.dart';

@HiveType(typeId: 2)
class MaintenanceTask {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String roadName;

  @HiveField(4)
  final String taskType; // 日常养护、专项维修、应急抢修

  @HiveField(5)
  final String status; // 待分配、进行中、已完成、已验收

  @HiveField(6)
  final String? assignee; // 负责人

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? startTime;

  @HiveField(9)
  final DateTime? completedAt;

  @HiveField(10)
  final String priority; // 低、中、高、紧急

  @HiveField(11)
  final double? latitude;

  @HiveField(12)
  final double? longitude;

  @HiveField(13)
  final List<String>? photos;

  @HiveField(14)
  final String? remarks;

  MaintenanceTask({
    required this.id,
    required this.title,
    required this.description,
    required this.roadName,
    required this.taskType,
    required this.status,
    this.assignee,
    required this.createdAt,
    this.startTime,
    this.completedAt,
    required this.priority,
    this.latitude,
    this.longitude,
    this.photos,
    this.remarks,
  });

  MaintenanceTask copyWith({
    String? status,
    String? assignee,
    DateTime? startTime,
    DateTime? completedAt,
    List<String>? photos,
    String? remarks,
  }) {
    return MaintenanceTask(
      id: id,
      title: title,
      description: description,
      roadName: roadName,
      taskType: taskType,
      status: status ?? this.status,
      assignee: assignee ?? this.assignee,
      createdAt: createdAt,
      startTime: startTime ?? this.startTime,
      completedAt: completedAt ?? this.completedAt,
      priority: priority,
      latitude: latitude,
      longitude: longitude,
      photos: photos ?? this.photos,
      remarks: remarks ?? this.remarks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'roadName': roadName,
      'taskType': taskType,
      'status': status,
      'assignee': assignee,
      'createdAt': createdAt.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'priority': priority,
      'latitude': latitude,
      'longitude': longitude,
      'photos': photos,
      'remarks': remarks,
    };
  }
}
