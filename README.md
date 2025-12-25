# 公路养护移动应用

基于Flutter的多平台公路养护管理系统，支持Android、iOS、HarmonyOS

## 核心功能

### ✅ 已完成

#### 1. 用户认证
- ✅ 登录/登出功能
- ✅ Token持久化存储
- ✅ 自动登录状态恢复

#### 2. 轨迹记录（类似悦跑圈/咕咚）
- ✅ **息屏后台记录**：使用前台服务持续记录
- ✅ **自动轨迹纠偏**：
  - 精度过滤（<100米）
  - 速度过滤（<50m/s）
  - 距离过滤（5米阈值）
- ✅ **高德地图集成**：
  - 实时定位显示
  - 轨迹绘制
  - 地图样式切换
- ✅ **本地存储**：Hive数据库持久化

#### 3. 病害拍照记录
- ✅ **多图拍照**：支持拍照和相册选择
- ✅ **位置定位**：自动获取病害位置
- ✅ **分类管理**：
  - 病害类型：裂缝、坑槽、沉陷、松散、波浪
  - 严重程度：轻微、中等、严重
- ✅ **离线存储**：本地数据库保存

#### 4. 任务管理
- ✅ **任务创建**：支持创建养护任务
- ✅ **任务分类**：
  - 任务类型：日常养护、专项维修、应急抢修
  - 优先级：低、中、高、紧急
- ✅ **状态跟踪**：
  - 待分配、进行中、已完成、已验收
  - 任务详情查看
  - 状态更新
- ✅ **任务列表**：按状态分类展示

#### 5. 统计报表
- ✅ **数据概览**：病害数量、任务统计
- ✅ **病害分布**：按类型统计展示
- ✅ **任务分析**：按状态统计展示
- ✅ **最近活动**：实时显示最新任务

#### 6. 离线数据同步 ⭐
- ✅ **网络检测**：自动检测网络状态
- ✅ **后台同步**：
  - 定时自动同步（5分钟）
  - 网络恢复时立即同步
  - 手动触发同步
- ✅ **数据标记**：synced字段追踪同步状态
- ✅ **UI提示**：
  - 同步状态实时显示
  - 未同步数量提醒
  - 同步进度展示
- ✅ **双向同步**：
  - 上传本地数据到服务器
  - 下载服务器更新到本地

#### 7. HarmonyOS适配 🎯
- ✅ **平台检测**：自动识别HarmonyOS设备
- ✅ **平台适配器**：统一API抽象平台差异
- ✅ **UI自适应**：
  - HarmonyOS大圆角设计
  - 平台标识显示
  - 响应式布局
- ✅ **开发文档**：完整HarmonyOS适配指南
- ✅ **代码就绪**：预留HarmonyOS分支逻辑
- ⏳ **待测试**：需HarmonyOS环境真机验证

## 平台支持

### 🎯 多平台兼容

| 平台 | 开发状态 | 测试状态 | 发布状态 |
|------|---------|---------|---------|
| **Android** | ✅ 完成 | ✅ 已测试 | ✅ 可发布 |
| **iOS** | ✅ 完成 | ✅ 已测试 | ✅ 可发布 |
| **HarmonyOS** | ✅ 代码就绪 | ⏳ 待测试 | ⏳ 需OHOS环境 |

### 📱 HarmonyOS适配说明

**当前状态：方案B - 平台检测 + 条件适配**

```
✅ 已完成：
- 平台检测器（自动识别鸿蒙设备）
- 平台适配器（统一API）
- UI自适应（鸿蒙设计规范）
- 条件编译预留

⏳ 需要时：
- 切换到Flutter OHOS分支
- 安装DevEco Studio
- 真机编译测试
- 打包.hap文件
```

详见：[docs/HARMONYOS_GUIDE.md](docs/HARMONYOS_GUIDE.md)

## 技术架构

```
lib/
├── core/                      # 核心模块
│   ├── config/               # 配置
│   │   └── app_config.dart   # API配置（Mock开关）
│   ├── theme/                # 主题
│   ├── routes/               # 路由
│   ├── platform/             # 平台适配 🆕
│   │   ├── platform_detector.dart  # 平台检测
│   │   └── platform_adapter.dart   # 平台适配器
│   ├── services/             # 服务
│   │   ├── sync_service.dart       # 同步服务
│   │   ├── mock_api_service.dart   # Mock API
│   │   ├── real_api_service.dart   # 真实API
│   │   └── api_service_factory.dart# API工厂
│   └── providers/            # 全局Provider
│       └── sync_provider.dart# 同步状态管理
├── features/                 # 功能模块
│   ├── auth/                # 认证
│   ├── inspection/          # 巡查（轨迹+病害）
│   ├── maintenance/         # 养护
│   └── report/              # 报表
└── shared/                  # 共享组件
    └── widgets/
        └── sync_status_widget.dart # 同步状态UI
```

## 核心技术

| 功能 | 技术方案 | 平台支持 |
|------|---------|---------|
| 状态管理 | Provider | ✅ 全平台 |
| 定位服务 | 高德地图SDK | Android/iOS |
| 后台任务 | flutter_background_service | Android/iOS |
| 轨迹纠偏 | Geolocator + 自定义算法 | ✅ 全平台 |
| 本地存储 | Hive + SharedPreferences | ✅ 全平台 |
| 数据同步 | connectivity_plus + Dio | ✅ 全平台 |
| 图片处理 | image_picker | 需平台适配 |
| 数据可视化 | fl_chart | ✅ 全平台 |
| 平台检测 | 自定义PlatformDetector | ✅ 全平台 |

## 快速开始

### 1. 环境要求
- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- 高德地图API Key（Android/iOS）

### 2. 克隆项目

```bash
git clone https://github.com/rowan766/flutter-road-maintenance.git
cd flutter-road-maintenance
```

### 3. 配置高德Key

详见 [docs/MAP_SETUP.md](docs/MAP_SETUP.md)

### 4. 安装依赖

```bash
flutter pub get

# 生成Hive适配器
flutter packages pub run build_runner build
```

### 5. 运行

```bash
# Android
flutter run -d android

# iOS (需要真机)
flutter run -d ios

# HarmonyOS (需要OHOS环境)
# 详见 docs/HARMONYOS_GUIDE.md
```

## 平台特性对比

### Android vs iOS vs HarmonyOS

| 特性 | Android | iOS | HarmonyOS |
|------|---------|-----|-----------|
| **圆角设计** | 8dp | 10pt | 16vp（更大）|
| **阴影** | elevation 4 | shadow 1 | elevation 2 |
| **图片选择** | 需要权限 | 需要权限 | System Picker无需权限 |
| **文件存储** | /data/data/... | Documents/ | /data/storage/... |
| **最大图片** | 5MB | 5MB | 10MB（推荐）|

## 使用场景

### 场景1：外业巡查（无网）

```
外业工作人员在野外
  ↓
拍摄病害照片
  ↓
数据保存到本地（synced=false）
  ↓
继续工作，不受网络影响
  ↓
平台自动适配（Android/iOS/HarmonyOS）
```

### 场景2：回到办公室（有网）

```
连接WiFi
  ↓
SyncService检测到网络
  ↓
自动上传所有未同步数据
  ↓
服务器保存成功
  ↓
本地标记synced=true
  ↓
同步完成（全平台）
```

## 数据模型

### TrackPoint（轨迹点）
```dart
latitude, longitude  # 经纬度
altitude, speed      # 海拔、速度
accuracy, timestamp  # 精度、时间
```

### RoadDefect（病害记录）
```dart
type, severity       # 类型、严重程度
photos, description  # 照片、描述
latitude, longitude  # 位置
synced              # 同步状态 ⭐
```

### MaintenanceTask（养护任务）
```dart
title, taskType      # 标题、类型
priority, status     # 优先级、状态
assignee, createdAt  # 负责人、时间
```

## 开发计划

- [x] 项目架构搭建
- [x] 用户认证模块
- [x] 后台轨迹记录
- [x] 轨迹自动纠偏
- [x] 高德地图集成
- [x] 病害拍照记录
- [x] 任务创建管理
- [x] 任务状态跟踪
- [x] 统计报表分析
- [x] 离线数据同步 ⭐
- [ ] 服务端API对接（Mock已就绪）
- [x] HarmonyOS适配（代码就绪，待环境测试）✅
- [ ] 多语言支持

## 文档

- 📖 [快速开始](docs/QUICK_START.md)
- 🗺️ [地图配置](docs/MAP_SETUP.md)
- 🔄 [离线同步](docs/OFFLINE_SYNC.md)
- 📱 [HarmonyOS适配](docs/HARMONYOS_GUIDE.md) 🆕
- 🔌 [API对接](docs/API_INTEGRATION.md)
- 📋 [API规范](docs/API_SPEC.md)

## 注意事项

### 通用
1. ✅ 生成Hive适配器后才能运行
2. ✅ 首次运行需要授予位置、相机、网络权限
3. ⭐ **离线工作完全支持，有网时自动同步**

### Android
1. ✅ 确保已申请高德地图Key
2. ✅ 需要打包签名才能正常定位

### iOS
1. ✅ 需要真机调试
2. ✅ 需要配置高德地图Key

### HarmonyOS
1. ⏳ 当前代码已适配，可在Android运行
2. ⏳ 需要DevEco Studio环境才能编译鸿蒙版
3. ⏳ 详见 [HarmonyOS适配指南](docs/HARMONYOS_GUIDE.md)

## License

MIT
