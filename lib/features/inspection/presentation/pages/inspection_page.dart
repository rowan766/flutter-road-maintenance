import 'package:flutter/material.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import '../../data/services/location_service.dart';
import '../../data/services/background_tracking_service.dart';
import '../../domain/models/track_point.dart';

class InspectionPage extends StatefulWidget {
  const InspectionPage({super.key});

  @override
  State<InspectionPage> createState() => _InspectionPageState();
}

class _InspectionPageState extends State<InspectionPage> {
  final LocationService _locationService = LocationService();
  final BackgroundTrackingService _bgService = BackgroundTrackingService();
  
  AMapController? _mapController;
  final List<TrackPoint> _trackPoints = [];
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    await _locationService.initialize();
    await _bgService.initialize();
    
    _locationService.trackPointsStream.listen((point) {
      setState(() {
        _trackPoints.add(point);
        _updatePolyline();
      });
    });
  }

  void _updatePolyline() {
    if (_mapController == null || _trackPoints.length < 2) return;

    final points = _trackPoints.map((p) => 
      LatLng(p.latitude, p.longitude)
    ).toList();

    // 这里可以更新地图上的轨迹线
  }

  Future<void> _toggleTracking() async {
    if (_isTracking) {
      await _bgService.stopBackgroundTracking();
      await _locationService.stopTracking();
    } else {
      await _bgService.startBackgroundTracking();
    }
    setState(() => _isTracking = !_isTracking);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('道路巡查'),
        actions: [
          IconButton(
            icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
            onPressed: _toggleTracking,
          ),
        ],
      ),
      body: Stack(
        children: [
          AMapWidget(
            apiKey: const AMapApiKey(
              androidKey: 'YOUR_ANDROID_KEY',
              iosKey: 'YOUR_IOS_KEY',
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            mapType: MapType.normal,
            buildingsEnabled: true,
            compassEnabled: true,
            scaleEnabled: true,
            myLocationStyleOptions: MyLocationStyleOptions(true),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isTracking ? '记录中...' : '未开始',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('轨迹点: ${_trackPoints.length}'),
                    if (_trackPoints.isNotEmpty)
                      Text(
                        '最后位置: ${_trackPoints.last.latitude.toStringAsFixed(6)}, '
                        '${_trackPoints.last.longitude.toStringAsFixed(6)}',
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }
}
