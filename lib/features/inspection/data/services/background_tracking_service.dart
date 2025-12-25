import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/track_point.dart';
import 'location_service.dart';

class BackgroundTrackingService {
  static final BackgroundTrackingService _instance = 
      BackgroundTrackingService._internal();
  factory BackgroundTrackingService() => _instance;
  BackgroundTrackingService._internal();

  final service = FlutterBackgroundService();

  Future<void> initialize() async {
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'road_maintenance_tracking',
        initialNotificationTitle: '公路养护',
        initialNotificationContent: '轨迹记录中...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  Future<void> startBackgroundTracking() async {
    await service.startService();
  }

  Future<void> stopBackgroundTracking() async {
    service.invoke('stop');
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    await Hive.initFlutter();
    Hive.registerAdapter(TrackPointAdapter());
    final box = await Hive.openBox<TrackPoint>('track_points');

    final locationService = LocationService();
    await locationService.initialize();

    StreamSubscription? trackSubscription;

    service.on('stop').listen((event) async {
      await trackSubscription?.cancel();
      await locationService.stopTracking();
      await box.close();
      service.stopSelf();
    });

    await locationService.startTracking();

    trackSubscription = locationService.trackPointsStream.listen(
      (point) async {
        // 保存轨迹点
        await box.add(point);

        // 更新通知
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: '轨迹记录中',
            content: '已记录 ${box.length} 个点',
          );
        }

        // 发送到UI
        service.invoke('update', {
          'latitude': point.latitude,
          'longitude': point.longitude,
          'count': box.length,
        });
      },
    );
  }
}
