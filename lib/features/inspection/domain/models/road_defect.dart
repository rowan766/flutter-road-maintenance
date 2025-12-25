import 'package:hive/hive.dart';

part 'road_defect.g.dart';

@HiveType(typeId: 1)
class RoadDefect {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type; // 病害类型：裂缝、坑槽、沉陷等

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double latitude;

  @HiveField(4)
  final double longitude;

  @HiveField(5)
  final List<String> photos; // 照片路径列表

  @HiveField(6)
  final String severity; // 严重程度：轻微、中等、严重

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final String? roadName;

  @HiveField(9)
  final bool synced; // 是否已同步到服务器

  RoadDefect({
    required this.id,
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.photos,
    required this.severity,
    required this.createdAt,
    this.roadName,
    this.synced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'photos': photos,
      'severity': severity,
      'createdAt': createdAt.toIso8601String(),
      'roadName': roadName,
      'synced': synced,
    };
  }

  RoadDefect copyWith({bool? synced}) {
    return RoadDefect(
      id: id,
      type: type,
      description: description,
      latitude: latitude,
      longitude: longitude,
      photos: photos,
      severity: severity,
      createdAt: createdAt,
      roadName: roadName,
      synced: synced ?? this.synced,
    );
  }
}
