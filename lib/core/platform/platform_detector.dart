import 'dart:io';
import 'package:flutter/foundation.dart';

/// 平台检测器
/// 用于检测应用运行的平台（Android、iOS、HarmonyOS等）
class PlatformDetector {
  // 私有构造函数，防止实例化
  PlatformDetector._();

  /// 是否为HarmonyOS
  /// 
  /// 检测方式：
  /// 1. 检查环境变量 OHOS_SDK_HOME
  /// 2. 检查系统属性 ro.build.version.ohos
  /// 3. 检查是否定义了 dart.library.ohos
  static bool get isHarmonyOS {
    if (kIsWeb) return false;
    
    // 方法1: 检查环境变量
    try {
      final ohosEnv = Platform.environment['OHOS_SDK_HOME'];
      if (ohosEnv != null && ohosEnv.isNotEmpty) {
        return true;
      }
    } catch (_) {}
    
    // 方法2: 检查Dart定义
    const bool kIsOHOS = bool.fromEnvironment('dart.library.ohos');
    if (kIsOHOS) return true;
    
    // 方法3: 通过操作系统版本字符串判断
    // HarmonyOS设备的Platform.operatingSystemVersion会包含"OpenHarmony"或"HarmonyOS"
    if (Platform.isAndroid) {
      try {
        final version = Platform.operatingSystemVersion.toLowerCase();
        if (version.contains('harmonyos') || 
            version.contains('openharmony') ||
            version.contains('ohos')) {
          return true;
        }
      } catch (_) {}
    }
    
    return false;
  }

  /// 是否为Android（不包括HarmonyOS）
  static bool get isAndroid {
    if (kIsWeb) return false;
    return Platform.isAndroid && !isHarmonyOS;
  }

  /// 是否为iOS
  static bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  /// 是否为macOS
  static bool get isMacOS {
    if (kIsWeb) return false;
    return Platform.isMacOS;
  }

  /// 是否为Windows
  static bool get isWindows {
    if (kIsWeb) return false;
    return Platform.isWindows;
  }

  /// 是否为Linux
  static bool get isLinux {
    if (kIsWeb) return false;
    return Platform.isLinux;
  }

  /// 是否为Web
  static bool get isWeb => kIsWeb;

  /// 是否为移动平台（Android、iOS、HarmonyOS）
  static bool get isMobile => isAndroid || isIOS || isHarmonyOS;

  /// 是否为桌面平台（Windows、macOS、Linux）
  static bool get isDesktop => isWindows || isMacOS || isLinux;

  /// 获取平台名称
  static String get platformName {
    if (isHarmonyOS) return 'HarmonyOS';
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isMacOS) return 'macOS';
    if (isWindows) return 'Windows';
    if (isLinux) return 'Linux';
    if (isWeb) return 'Web';
    return 'Unknown';
  }

  /// 获取操作系统版本
  static String get osVersion {
    if (kIsWeb) return 'Web';
    try {
      return Platform.operatingSystemVersion;
    } catch (_) {
      return 'Unknown';
    }
  }

  /// 获取设备信息摘要
  static Map<String, dynamic> get deviceInfo => {
    'platform': platformName,
    'osVersion': osVersion,
    'isMobile': isMobile,
    'isDesktop': isDesktop,
    'isWeb': isWeb,
  };

  /// 打印平台信息（用于调试）
  static void printInfo() {
    print('========== 平台信息 ==========');
    print('平台: $platformName');
    print('系统版本: $osVersion');
    print('移动平台: $isMobile');
    print('桌面平台: $isDesktop');
    print('Web平台: $isWeb');
    print('============================');
  }
}
