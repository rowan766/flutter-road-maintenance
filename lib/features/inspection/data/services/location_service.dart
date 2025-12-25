import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/track_point.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final AMapFlutterLocation _locationPlugin = AMapFlutterLocation();
  StreamSubscription<Map<String, Object>>? _locationSubscription;
  final _trackPointsController = StreamController<TrackPoint>.broadcast();

  Stream<TrackPoint> get trackPointsStream => _trackPointsController.stream;
  
  bool _isTracking = false;
  bool get isTracking => _isTracking;

  // 轨迹纠偏参数
  TrackPoint? _lastPoint;
  static const double _maxSpeed = 50.0; // 最大合理速度 m/s
  static const double _minAccuracy = 100.0; // 最小精度阈值

  Future<bool> requestPermissions() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      await Permission.locationAlways.request();
      return true;
    }
    return false;
  }

  Future<void> initialize() async {
    // 设置高德定位参数
    AMapFlutterLocation.setApiKey(
      'YOUR_ANDROID_KEY', // 替换为你的高德Android Key
      'YOUR_IOS_KEY',     // 替换为你的高德iOS Key
    );

    // 配置定位参数
    _locationPlugin.setLocationOption(AMapLocationOption(
      locationMode: AMapLocationMode.hight_Accuracy,
      gpsFirst: true,
      needAddress: false,
      onceLocation: false,
      onceLocationLatest: false,
      locationInterval: 2000, // 2秒更新一次
      distanceFilter: 5, // 5米更新一次
    ));
  }

  Future<void> startTracking() async {
    if (_isTracking) return;

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('位置权限未授予');
    }

    _isTracking = true;
    _lastPoint = null;

    _locationSubscription = _locationPlugin
        .onLocationChanged()
        .listen(_handleLocationUpdate);

    await _locationPlugin.startLocation();
  }

  void _handleLocationUpdate(Map<String, Object> location) {
    final lat = location['latitude'] as double?;
    final lng = location['longitude'] as double?;
    final accuracy = location['accuracy'] as double?;
    final speed = location['speed'] as double?;
    final altitude = location['altitude'] as double?;

    if (lat == null || lng == null) return;

    final point = TrackPoint(
      latitude: lat,
      longitude: lng,
      altitude: altitude,
      speed: speed,
      accuracy: accuracy,
      timestamp: DateTime.now(),
    );

    // 轨迹纠偏
    if (_shouldAcceptPoint(point)) {
      _lastPoint = point;
      _trackPointsController.add(point);
    }
  }

  bool _shouldAcceptPoint(TrackPoint point) {
    // 精度过低，拒绝
    if (point.accuracy != null && point.accuracy! > _minAccuracy) {
      return false;
    }

    if (_lastPoint == null) return true;

    // 计算距离
    final distance = Geolocator.distanceBetween(
      _lastPoint!.latitude,
      _lastPoint!.longitude,
      point.latitude,
      point.longitude,
    );

    // 计算时间差
    final timeDiff = point.timestamp.difference(_lastPoint!.timestamp).inSeconds;
    if (timeDiff == 0) return false;

    // 计算速度
    final calculatedSpeed = distance / timeDiff;

    // 速度不合理，拒绝
    if (calculatedSpeed > _maxSpeed) {
      return false;
    }

    return true;
  }

  Future<void> stopTracking() async {
    if (!_isTracking) return;

    _isTracking = false;
    await _locationSubscription?.cancel();
    await _locationPlugin.stopLocation();
    _lastPoint = null;
  }

  void dispose() {
    _locationSubscription?.cancel();
    _trackPointsController.close();
    _locationPlugin.destroy();
  }
}
