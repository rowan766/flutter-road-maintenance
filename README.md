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
│   │   ├── domain/models/   # 轨迹点、病害模型
│   │   ├── data/services/   # 定位&后台服务
│   │   └── presentation/    # 地图、病害记录页面
│   ├── maintenance/         # 养护
│   │   ├── domain/models/   # 任务模型
│   │   └── presentation/    # 任务列表、详情、创建
│   └── report/              # 报表
│       └── presentation/    # 统计图表页面
└── shared/                  # 共享组件
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
| 图片处理 | image_picker |
| 数据可视化 | fl_chart |
| 网络请求 | Dio |

## 功能详解

### 后台定位
**Android**
- 使用前台服务（Foreground Service）
- 通知栏显示记录状态
- 息屏后持续定位

**iOS**  
- 配置后台模式（Background Modes）
- 需要"始终允许"定位权限
- 真机调试

### 轨迹纠偏算法
```dart
// 1. 精度过滤
if (accuracy > 100m) reject;

// 2. 速度过滤
speed = distance / timeDiff;
if (speed > 50m/s) reject;

// 3. 距离过滤
if (distance < 5m) skip;
```

### 病害记录流程
1. 打开病害记录页面
2. 自动获取GPS位置
3. 选择病害类型和严重程度
4. 拍照或从相册选择
5. 填写描述信息
6. 保存到本地数据库

### 任务管理流程
1. 创建任务（标题、类型、优先级）
2. 分配任务给负责人
3. 任务执行（更新状态）
4. 任务完成（上传照片）
5. 验收确认

## 数据模型

### TrackPoint（轨迹点）
```dart
- latitude, longitude  # 经纬度
- altitude             # 海拔
- speed                # 速度
- accuracy             # 精度
- timestamp            # 时间戳
```

### RoadDefect（病害记录）
```dart
- type                 # 病害类型
- severity             # 严重程度
- description          # 描述
- photos               # 照片列表
- latitude, longitude  # 位置
- createdAt            # 创建时间
```

### MaintenanceTask（养护任务）
```dart
- title, description   # 标题、描述
- taskType             # 任务类型
- priority             # 优先级
- status               # 状态
- assignee             # 负责人
- createdAt            # 创建时间
- startTime            # 开始时间
- completedAt          # 完成时间
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
- [ ] 离线数据同步
- [ ] 服务端API对接
- [ ] HarmonyOS适配
- [ ] 多语言支持

## 截图预览

### 主页
- 道路巡查入口
- 病害记录入口
- 养护管理入口
- 统计报表入口

### 巡查页面
- 实时地图显示
- 轨迹记录控制
- 轨迹点统计

### 病害记录
- 拍照上传
- 位置定位
- 类型选择
- 严重程度评估

### 养护管理
- 任务列表（按状态分类）
- 任务详情
- 状态更新

### 统计报表
- 数据概览卡片
- 病害类型分布
- 任务状态分布
- 最近活动列表

## 注意事项

1. 确保已申请高德地图Key
2. Android需要打包签名才能正常定位
3. iOS需要真机调试
4. 首次运行需要授予位置权限和相机权限
5. 生成Hive适配器后才能运行

## License

MIT
