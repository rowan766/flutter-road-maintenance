# 地图和定位配置指南

## 高德地图配置

### 1. 申请高德Key

访问 [高德开放平台](https://lbs.amap.com/) 注册并创建应用：
- Android平台需要SHA1
- iOS平台需要Bundle ID

### 2. Android配置

在 `android/app/src/main/AndroidManifest.xml` 添加：

```xml
<manifest>
    <!-- 权限 -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    
    <application>
        <!-- 高德Key -->
        <meta-data
            android:name="com.amap.api.v2.apikey"
            android:value="YOUR_ANDROID_KEY"/>
    </application>
</manifest>
```

在 `android/app/build.gradle` 中设置：
```gradle
android {
    defaultConfig {
        minSdkVersion 21  // 最低21
    }
}
```

### 3. iOS配置

在 `ios/Runner/Info.plist` 添加：

```xml
<key>AMapApiKey</key>
<string>YOUR_IOS_KEY</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>需要访问位置以记录巡查轨迹</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>需要后台定位以持续记录轨迹</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>需要后台定位以持续记录轨迹</string>

<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>fetch</string>
    <string>processing</string>
</array>
```

### 4. 替换API Key

在以下文件中替换YOUR_ANDROID_KEY和YOUR_IOS_KEY：
- `lib/features/inspection/data/services/location_service.dart`
- `lib/features/inspection/presentation/pages/inspection_page.dart`

## 功能特性

### 轨迹纠偏
- 精度过滤：拒绝精度低于100米的点
- 速度过滤：拒绝速度超过50m/s的异常点
- 距离过滤：5米以上才记录新点

### 后台定位
- 息屏后继续记录轨迹
- 前台通知显示记录状态
- 数据本地持久化存储

### 使用方法

```dart
// 初始化
await LocationService().initialize();
await BackgroundTrackingService().initialize();

// 开始记录
await BackgroundTrackingService().startBackgroundTracking();

// 停止记录
await BackgroundTrackingService().stopBackgroundTracking();
```

## 注意事项

1. 确保已申请高德地图Key
2. Android需要打包签名才能正常定位
3. iOS需要真机调试
4. 首次运行需要授予位置权限
