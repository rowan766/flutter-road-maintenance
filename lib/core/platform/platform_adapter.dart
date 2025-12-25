import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'platform_detector.dart';

/// 平台适配器
/// 提供跨平台的统一API，自动处理不同平台的差异
class PlatformAdapter {
  // 单例模式
  static final PlatformAdapter _instance = PlatformAdapter._internal();
  factory PlatformAdapter() => _instance;
  PlatformAdapter._internal();

  /// 获取应用文档目录
  /// 
  /// 不同平台路径：
  /// - Android: /data/data/包名/app_flutter
  /// - iOS: /var/mobile/Containers/Data/Application/UUID/Documents
  /// - HarmonyOS: /data/storage/el2/base/haps/entry/files
  Future<String> getDocumentsPath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } catch (e) {
      // 降级方案：使用临时目录
      final tempDir = await getTemporaryDirectory();
      return tempDir.path;
    }
  }

  /// 获取临时目录
  Future<String> getTemporaryPath() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  /// 获取应用支持目录
  Future<String> getApplicationSupportPath() async {
    try {
      final directory = await getApplicationSupportDirectory();
      return directory.path;
    } catch (e) {
      return await getDocumentsPath();
    }
  }

  /// 获取缓存目录
  Future<String> getCachePath() async {
    if (PlatformDetector.isHarmonyOS) {
      // HarmonyOS缓存目录
      return '${await getApplicationSupportPath()}/cache';
    } else {
      // Android/iOS使用系统缓存目录
      final directory = await getTemporaryDirectory();
      return '${directory.path}/cache';
    }
  }

  /// 创建目录（如果不存在）
  Future<Directory> ensureDirectoryExists(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// 获取文件大小（MB）
  Future<double> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final bytes = await file.length();
        return bytes / (1024 * 1024); // 转换为MB
      }
    } catch (_) {}
    return 0;
  }

  /// 删除文件
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// 清理缓存
  Future<void> clearCache() async {
    try {
      final cachePath = await getCachePath();
      final cacheDir = Directory(cachePath);
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await ensureDirectoryExists(cachePath);
      }
    } catch (e) {
      print('清理缓存失败: $e');
    }
  }

  /// 获取平台特定配置
  Map<String, dynamic> getPlatformConfig() {
    if (PlatformDetector.isHarmonyOS) {
      return {
        'maxImageSize': 10 * 1024 * 1024, // 10MB
        'compressionQuality': 80,
        'useSystemPicker': true, // HarmonyOS使用System Picker
        'requiresPermission': false, // System Picker无需权限
      };
    } else if (PlatformDetector.isAndroid) {
      return {
        'maxImageSize': 5 * 1024 * 1024, // 5MB
        'compressionQuality': 85,
        'useSystemPicker': false,
        'requiresPermission': true,
      };
    } else if (PlatformDetector.isIOS) {
      return {
        'maxImageSize': 5 * 1024 * 1024, // 5MB
        'compressionQuality': 90,
        'useSystemPicker': false,
        'requiresPermission': true,
      };
    }
    
    // 默认配置
    return {
      'maxImageSize': 5 * 1024 * 1024,
      'compressionQuality': 85,
      'useSystemPicker': false,
      'requiresPermission': true,
    };
  }

  /// 获取推荐的UI参数
  Map<String, double> getUIConfig() {
    if (PlatformDetector.isHarmonyOS) {
      return {
        'borderRadius': 16.0, // 鸿蒙推荐大圆角
        'elevation': 2.0,
        'spacing': 16.0,
        'iconSize': 24.0,
      };
    } else if (PlatformDetector.isAndroid) {
      return {
        'borderRadius': 8.0, // Material Design
        'elevation': 4.0,
        'spacing': 16.0,
        'iconSize': 24.0,
      };
    } else if (PlatformDetector.isIOS) {
      return {
        'borderRadius': 10.0, // iOS圆角
        'elevation': 1.0,
        'spacing': 20.0,
        'iconSize': 22.0,
      };
    }
    
    return {
      'borderRadius': 8.0,
      'elevation': 2.0,
      'spacing': 16.0,
      'iconSize': 24.0,
    };
  }

  /// 获取平台信息摘要
  Map<String, dynamic> getPlatformSummary() {
    return {
      ...PlatformDetector.deviceInfo,
      'config': getPlatformConfig(),
      'uiConfig': getUIConfig(),
    };
  }

  /// 打印平台适配信息
  void printAdapterInfo() {
    print('========== 平台适配信息 ==========');
    print('平台: ${PlatformDetector.platformName}');
    print('配置: ${getPlatformConfig()}');
    print('UI配置: ${getUIConfig()}');
    print('================================');
  }
}
