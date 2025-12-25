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

## 技术架构

```
lib/
├── core/                      # 核心模块
│   ├── config/               # 配置
│   ├── theme/                # 主题
│   ├── routes/               # 路由
│   ├── services/             # 服务
│   │   └── sync_service.dart # 同步服务
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

## 离线同步机制

### 工作流程

```
用户操作（拍照/记录）
        ↓
保存到本地Hive（synced=false）
        ↓
SyncService检测网络
        ↓
    有网络？
      / \
    是   否
    /     \
   ↓       ↓
自动同步  等待网络
服务器
   ↓
标记synced=true
```

### 核心特性

| 特性 | 说明 |
|------|------|
| **离线优先** | 所有操作先保存本地，不依赖网络 |
| **自动同步** | 网络恢复时自动上传 |
| **定时同步** | 每5分钟自动检查并同步 |
| **手动同步** | 用户可主动触发同步 |
| **状态提示** | 实时显示同步状态和未同步数量 |

详见：[docs/OFFLINE_SYNC.md](docs/OFFLINE_SYNC.md)

## 快速开始

### 1. 环境要求
- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- 高德地图API Key

### 2. 配置高德Key

详见 [docs/MAP_SETUP.md](docs/MAP_SETUP.md)

### 3. 安装依赖

```bash
flutter pub get

# 生成Hive适配器
flutter packages pub run build_runner build
```

### 4. 运行

```bash
# Android
flutter run -d android

# iOS (需要真机)
flutter run -d ios
```

## 核心技术

| 功能 | 技术方案 |
|------|---------|
| 状态管理 | Provider |
| 定位服务 | 高德地图SDK |
| 后台任务 | flutter_background_service |
| 轨迹纠偏 | Geolocator + 自定义算法 |
| 本地存储 | Hive + SharedPreferences |
| 数据同步 | connectivity_plus + Dio |
| 图片处理 | image_picker |
| 数据可视化 | fl_chart |

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
同步完成
```

### 场景3：多人协作

```
A用户创建任务（有网）→ 上传服务器
  ↓
B用户打开APP（有网）→ 自动下载
  ↓
B用户收到新任务通知
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
- [ ] 服务端API对接
- [ ] HarmonyOS适配
- [ ] 多语言支持

## 文档

- 📖 [快速开始](docs/QUICK_START.md)
- 🗺️ [地图配置](docs/MAP_SETUP.md)
- 🔄 [离线同步](docs/OFFLINE_SYNC.md)

## 注意事项

1. ✅ 确保已申请高德地图Key
2. ✅ Android需要打包签名才能正常定位
3. ✅ iOS需要真机调试
4. ✅ 首次运行需要授予位置、相机、网络权限
5. ✅ 生成Hive适配器后才能运行
6. ⭐ **离线工作完全支持，有网时自动同步**

## License

MIT
