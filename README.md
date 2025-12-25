# 公路养护移动应用

基于Flutter的多平台公路养护管理系统，支持Android、iOS、HarmonyOS

## 核心功能

### ✅ 已完成

#### 1. 用户认证
- 登录/登出功能
- Token持久化存储
- 自动登录状态恢复

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

### 🚧 待开发
- 病害拍照记录
- 任务管理
- 统计报表
- HarmonyOS适配

## 技术架构

```
lib/
├── core/                      # 核心模块
│   ├── config/               # 配置
│   ├── theme/                # 主题
│   └── routes/               # 路由
├── features/                 # 功能模块
│   ├── auth/                # 认证
│   │   ├── domain/models/   # 用户模型
│   │   └── presentation/    # UI & Provider
│   ├── inspection/          # 巡查
│   │   ├── domain/models/   # 轨迹点模型
│   │   ├── data/services/   # 定位&后台服务
│   │   └── presentation/    # 地图页面
│   ├── maintenance/         # 养护
│   └── report/              # 报表
└── shared/                   # 共享组件
```

## 快速开始

### 1. 环境要求
- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- 高德地图API Key

### 2. 配置高德Key

详见 [docs/MAP_SETUP.md](docs/MAP_SETUP.md)

**关键步骤：**
1. 访问[高德开放平台](https://lbs.amap.com/)申请Key
2. 替换以下文件中的API Key：
   - `lib/features/inspection/data/services/location_service.dart`
   - `lib/features/inspection/presentation/pages/inspection_page.dart`

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
| 网络请求 | Dio |

## 后台定位说明

### Android
- 使用前台服务（Foreground Service）
- 通知栏显示记录状态
- 息屏后持续定位

### iOS  
- 配置后台模式（Background Modes）
- 需要"始终允许"定位权限
- 真机调试

## 轨迹纠偏算法

```dart
// 1. 精度过滤
if (accuracy > 100m) reject;

// 2. 速度过滤
speed = distance / timeDiff;
if (speed > 50m/s) reject;

// 3. 距离过滤
if (distance < 5m) skip;
```

## 开发计划

- [x] 项目架构搭建
- [x] 用户认证模块
- [x] 后台轨迹记录
- [x] 轨迹自动纠偏
- [x] 高德地图集成
- [ ] 病害拍照记录
- [ ] 离线数据同步
- [ ] 任务分配管理
- [ ] 数据统计报表
- [ ] HarmonyOS适配

## License

MIT
