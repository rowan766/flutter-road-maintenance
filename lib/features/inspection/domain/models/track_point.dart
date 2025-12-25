import 'package:hive/hive.dart';

part 'track_point.g.dart';

@HiveType(typeId: 0)
class TrackPoint {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final double? altitude;

  @HiveField(3)
  final double? speed;

  @HiveField(4)
  final double? accuracy;

  @HiveField(5)
  final DateTime timestamp;

  TrackPoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
    this.accuracy,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'speed': speed,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
