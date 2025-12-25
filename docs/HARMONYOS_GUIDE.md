# HarmonyOS适配指南

## 📋 概述

本文档介绍如何将Flutter应用适配到HarmonyOS NEXT系统。

## 🎯 适配方案

### 方案对比

| 方案 | 说明 | 优势 | 劣势 | 推荐场景 |
|------|------|------|------|---------|
| **方案A：完整原生** | 使用Flutter OHOS分支 | 完全原生支持 | 需重建环境，成本高 | 生产发布 |
| **方案B：平台检测** | 现有项目添加适配层 | 渐进式，低成本 | 需条件编译 | 开发阶段 |

**当前采用：方案B（平台检测 + 条件适配）**

---

## 🛠️ 环境要求

### 开发HarmonyOS应用需要

#### 必需工具
- **DevEco Studio** ≥ 4.0 Beta2
- **HarmonyOS SDK** ≥ 5.0.0(12)
- **Node.js** ≥ 18.15.0
- **Flutter OHOS分支** 3.22.0-ohos

#### 设备要求
- **真机设备**（必须）：Mate60系列、P60系列等
- ⚠️ 模拟器仅支持x86，Flutter需要ARM64

---

## 📦 当前项目适配状态

### ✅ 已实现

#### 1. 平台检测层
- `lib/core/platform/platform_detector.dart`
- 运行时检测HarmonyOS
- 提供统一平台信息API

#### 2. 平台适配器
- `lib/core/platform/platform_adapter.dart`
- 统一文件路径、权限、存储API
- 自动适配不同平台差异

#### 3. 条件渲染
- UI组件根据平台自适应
- 功能降级策略

### ⏳ 待完成（需HarmonyOS环境）

- [ ] 使用Flutter OHOS分支编译
- [ ] 生成.hap安装包
- [ ] 真机测试验证
- [ ] 鸿蒙应用商店发布

---

## 🔧 快速开始

### 1. 使用当前代码（开发阶段）

当前代码已添加平台检测，可在Android/iOS正常运行：

```bash
# 正常运行
flutter run

# 平台会自动检测
# Android设备 → 识别为Android
# iOS设备 → 识别为iOS
# 鸿蒙设备 → 识别为HarmonyOS（需OHOS分支）
```

### 2. 完整HarmonyOS开发环境（生产阶段）

#### 步骤1：安装DevEco Studio

下载地址：https://developer.huawei.com/consumer/cn/download/

#### 步骤2：配置环境变量

**macOS/Linux:**
```bash
# ~/.zshrc 或 ~/.bash_profile

# HarmonyOS SDK
export TOOL_HOME=/Applications/DevEco-Studio.app/Contents/
export DEVECO_SDK_HOME=$TOOL_HOME/sdk
export PATH=$TOOL_HOME/tools/ohpm/bin:$PATH
export PATH=$TOOL_HOME/tools/hvigor/bin:$PATH
export PATH=$TOOL_HOME/tools/node/bin:$PATH

# Flutter Mirror (中国用户)
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```

**Windows:**
```
DEVECO_SDK_HOME=C:\Program Files\Huawei\DevEco Studio\sdk

添加到PATH:
C:\Program Files\Huawei\DevEco Studio\tools\ohpm\bin
C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin
C:\Program Files\Huawei\DevEco Studio\tools\node\bin
```

#### 步骤3：克隆Flutter OHOS分支

```bash
# 克隆OpenHarmony SIG的Flutter
git clone -b dev https://gitee.com/openharmony-sig/flutter_flutter.git

# 或使用FVM管理
cd ~/.fvm/versions/
git clone -b dev https://gitee.com/openharmony-sig/flutter_flutter.git custom_3.22.0
```

#### 步骤4：验证环境

```bash
flutter doctor -v
```

预期输出包含：
```
[✓] HarmonyOS toolchain - develop for HarmonyOS devices
  • OpenHarmony Sdk at [PATH]
  • Ohpm version 5.0.8-rc.1
  • Node version v18.20.1
```

#### 步骤5：创建HarmonyOS项目配置

```bash
# 在项目目录执行
flutter create --platforms=ohos .
```

#### 步骤6：构建HAP包

```bash
# Debug版本
flutter build hap --debug

# Release版本
flutter build hap --release
```

#### 步骤7：运行到真机

```bash
# 查看设备
flutter devices

# 运行到鸿蒙设备
flutter run -d <device_id>
```

---

## 💡 代码适配示例

### 平台检测

```dart
import 'package:road_maintenance/core/platform/platform_detector.dart';

void main() {
  if (PlatformDetector.isHarmonyOS) {
    print('运行在HarmonyOS上');
  } else if (PlatformDetector.isAndroid) {
    print('运行在Android上');
  }
}
```

### 条件渲染

```dart
Widget build(BuildContext context) {
  if (PlatformDetector.isHarmonyOS) {
    return HarmonyOSSpecificWidget();
  }
  return DefaultWidget();
}
```

### 平台特定功能

```dart
Future<void> requestPermission() async {
  final adapter = PlatformAdapter();
  
  if (PlatformDetector.isHarmonyOS) {
    // HarmonyOS使用System Picker，无需权限
    await adapter.pickImage();
  } else {
    // Android/iOS需要请求权限
    await Permission.camera.request();
  }
}
```

---

## 📱 插件适配

### 第三方插件HarmonyOS支持情况

| 插件 | 状态 | 替代方案 |
|------|------|---------|
| amap_flutter_map | ❌ 不支持 | 等待官方支持 |
| image_picker | ❌ 不支持 | 使用System Picker |
| permission_handler | ❌ 不支持 | 使用HarmonyOS原生API |
| hive | ✅ 支持 | 可正常使用 |
| dio | ✅ 支持 | 可正常使用 |
| provider | ✅ 支持 | 可正常使用 |

### 处理策略

```dart
// 使用平台适配器抽象差异
final adapter = PlatformAdapter();

// 自动选择最佳实现
final imagePath = await adapter.pickImage();
final location = await adapter.getCurrentLocation();
```

---

## 🎨 UI适配

### 响应式布局

```dart
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      // 适配不同屏幕尺寸
      if (constraints.maxWidth > 1200) {
        return DesktopLayout();
      } else if (constraints.maxWidth > 600) {
        return TabletLayout();
      } else {
        return MobileLayout();
      }
    },
  );
}
```

### 平台特定样式

```dart
// 鸿蒙设计规范
final double borderRadius = PlatformDetector.isHarmonyOS 
    ? 16.0  // 鸿蒙推荐大圆角
    : 8.0;  // Android Material
```

---

## 🔐 权限处理

### HarmonyOS vs Android权限差异

| 功能 | Android | HarmonyOS |
|------|---------|-----------|
| 相册访问 | 需要权限 | System Picker无需权限 |
| 相机 | 需要权限 | 需要权限 |
| 定位 | 需要权限 | 需要权限 |
| 存储 | 需要权限 | Sandbox自动管理 |

### 适配代码

```dart
Future<void> pickPhoto() async {
  if (PlatformDetector.isHarmonyOS) {
    // 使用System Picker，无需权限
    final picker = SystemPicker();
    final result = await picker.pickImage();
  } else {
    // Android需要先请求权限
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final picker = ImagePicker();
      final result = await picker.pickImage();
    }
  }
}
```

---

## 📦 资源适配

### 目录结构

```
assets/
├── images/
│   ├── common/        # 通用资源
│   ├── android/       # Android专用
│   ├── ios/           # iOS专用
│   └── harmonyos/     # HarmonyOS专用
└── fonts/
    └── harmonyos/     # 鸿蒙优化字体
```

### 动态加载

```dart
String getImagePath(String name) {
  if (PlatformDetector.isHarmonyOS) {
    return 'assets/images/harmonyos/$name';
  } else if (PlatformDetector.isAndroid) {
    return 'assets/images/android/$name';
  }
  return 'assets/images/common/$name';
}
```

---

## 🚀 发布流程

### 1. 生成签名证书

在DevEco Studio中：
- File → Project Structure → Signing Configs
- 勾选"Automatically generate signature"

### 2. 配置build-profile.json5

```json5
{
  "signAlg": "SHA256withECDSA",
  "storeFile": "${user.home}/.ohos/config/default_ohos_xxx.p12",
  "keyAlias": "debugKey",
  "profile": "${user.home}/.ohos/config/default_ohos_xxx.p7b",
  "compatibleSdkVersion": "5.0.0(12)"
}
```

### 3. 构建Release版本

```bash
flutter build hap --release
```

### 4. 上传华为应用市场

访问：https://developer.huawei.com/consumer/cn/appgallery/

---

## ⚠️ 常见问题

### Q1: flutter doctor报错"Unable to find git"

```bash
git config --global --add safe.directory '*'
```

### Q2: 模拟器无法运行

**A:** HarmonyOS模拟器仅支持x86，Flutter需要ARM64。请使用真机调试。

### Q3: 第三方插件不支持HarmonyOS

**A:** 
1. 查找OpenHarmony SIG是否有适配版本
2. 使用平台适配器抽象
3. 自行实现HarmonyOS版本

### Q4: 打包后无法安装

**A:** 检查签名配置和SDK版本兼容性

---

## 📚 参考资源

### 官方文档
- [HarmonyOS开发者官网](https://developer.huawei.com/)
- [OpenHarmony Flutter SIG](https://gitee.com/openharmony-sig)

### 社区资源
- [Flutter OHOS分支](https://gitee.com/openharmony-sig/flutter_flutter)
- [鸿蒙开发者论坛](https://developer.huawei.com/consumer/cn/forum/)

---

## 📝 总结

### 当前阶段（开发）

✅ 平台检测层已实现  
✅ 平台适配器已实现  
✅ 可在Android/iOS正常开发  
⏳ 待HarmonyOS环境测试  

### 生产阶段（发布）

需要：
1. 安装DevEco Studio
2. 配置HarmonyOS SDK
3. 使用Flutter OHOS分支
4. 真机测试
5. 打包HAP
6. 上架应用市场

**建议：先在Android/iOS完成功能开发，最后统一适配HarmonyOS。**
