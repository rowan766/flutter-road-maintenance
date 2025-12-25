# 快速开始指南

## 1. 克隆项目

```bash
git clone git@github.com:rowan766/flutter-road-maintenance.git
cd flutter-road-maintenance
```

## 2. 安装Flutter

确保已安装Flutter SDK >= 3.0.0

```bash
flutter --version
```

## 3. 安装依赖

```bash
flutter pub get
```

## 4. 生成代码

由于使用了Hive数据库，需要生成适配器代码：

```bash
flutter packages pub run build_runner build
```

如果遇到冲突，使用：
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## 5. 配置高德地图Key

### 5.1 申请Key

访问 [高德开放平台](https://lbs.amap.com/) 注册并创建应用：
- Android平台需要SHA1
- iOS平台需要Bundle ID

### 5.2 获取SHA1（Android）

```bash
# 调试证书
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# 发布证书
keytool -list -v -keystore /path/to/your/keystore.jks
```

### 5.3 替换API Key

在以下文件中替换YOUR_ANDROID_KEY和YOUR_IOS_KEY：

**文件1：** `lib/features/inspection/data/services/location_service.dart`
```dart
AMapFlutterLocation.setApiKey(
  'YOUR_ANDROID_KEY',  // 替换这里
  'YOUR_IOS_KEY',      // 替换这里
);
```

**文件2：** `lib/features/inspection/presentation/pages/inspection_page.dart`
```dart
apiKey: const AMapApiKey(
  androidKey: 'YOUR_ANDROID_KEY',  // 替换这里
  iosKey: 'YOUR_IOS_KEY',          // 替换这里
),
```

## 6. Android配置

### 6.1 修改AndroidManifest.xml

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
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    
    <application>
        <!-- 高德Key -->
        <meta-data
            android:name="com.amap.api.v2.apikey"
            android:value="YOUR_ANDROID_KEY"/>
    </application>
</manifest>
```

### 6.2 修改build.gradle

在 `android/app/build.gradle` 中确保：

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // 最低21
    }
}
```

## 7. iOS配置

### 7.1 修改Info.plist

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

<key>NSCameraUsageDescription</key>
<string>需要访问相机以拍摄病害照片</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册以选择照片</string>

<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>fetch</string>
    <string>processing</string>
</array>
```

### 7.2 安装Pods

```bash
cd ios
pod install
cd ..
```

## 8. 运行项目

### Android

```bash
# 连接Android设备或启动模拟器
flutter devices

# 运行
flutter run -d <device_id>
```

### iOS

```bash
# 连接iOS设备（需要真机，模拟器定位功能受限）
flutter devices

# 运行
flutter run -d <device_id>
```

## 9. 功能测试

### 9.1 登录
- 用户名：任意
- 密码：任意
- 系统会自动保存登录状态

### 9.2 轨迹记录
1. 进入"道路巡查"
2. 点击播放按钮开始记录
3. 息屏测试后台记录功能
4. 点击停止按钮结束记录

### 9.3 病害记录
1. 进入"病害记录"
2. 选择病害类型和严重程度
3. 拍照或从相册选择
4. 填写描述并保存

### 9.4 任务管理
1. 进入"养护管理"
2. 点击+创建新任务
3. 填写任务信息
4. 查看任务列表和详情

### 9.5 统计报表
1. 进入"统计报表"
2. 查看数据概览
3. 查看各类统计图表

## 10. 常见问题

### Q1: build_runner执行失败
```bash
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Q2: Android定位不准确
- 确保已添加高德Key到AndroidManifest.xml
- 检查是否授予了位置权限
- 使用签名证书的SHA1申请Key

### Q3: iOS真机无法定位
- 确保Info.plist配置正确
- 授予"始终允许"位置权限
- 检查iOS Key是否正确

### Q4: 图片拍照失败
- 检查相机权限是否授予
- Android需要存储权限
- iOS需要相机和相册权限

## 11. 打包发布

### Android APK

```bash
flutter build apk --release
```

生成的APK位于：`build/app/outputs/flutter-apk/app-release.apk`

### iOS IPA

```bash
flutter build ios --release
```

然后使用Xcode进行Archive和导出。

## 12. 下一步

- 对接后端API
- 实现数据同步
- 添加更多功能
- 优化性能

## 技术支持

如有问题，请查看：
- [docs/MAP_SETUP.md](MAP_SETUP.md) - 地图配置详细说明
- [GitHub Issues](https://github.com/rowan766/flutter-road-maintenance/issues)
