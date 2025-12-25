# 离线数据同步机制

## 📱 移动应用 vs PWA

### 区别对比

| 特性 | 移动应用（本项目） | PWA |
|------|-----------------|-----|
| **技术栈** | Hive本地数据库 | Service Worker + IndexedDB |
| **运行环境** | 原生应用 | 浏览器 |
| **后台能力** | ✅ 真正的后台服务 | ⚠️ 受限的后台 |
| **存储容量** | ✅ 几乎无限 | ⚠️ 受限（通常50MB-250MB） |
| **离线能力** | ✅ 完全离线 | ✅ 缓存离线 |
| **数据同步** | ✅ 自动后台同步 | ⚠️ 需要打开应用 |

## 🔄 同步机制设计

### 工作流程

```
┌─────────────┐
│ 用户操作    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ 本地存储    │ ← Hive数据库
│ (离线优先)  │   标记synced=false
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ 检测网络    │ ← connectivity_plus
└──────┬──────┘
       │
   有网？
      / \
    是   否
    /     \
   ▼       ▼
同步      等待
服务器    网络
   │
   ▼
标记synced=true
```

### 核心组件

#### 1. SyncService（同步服务）

**功能：**
- 🔍 监听网络状态
- ⏰ 定时自动同步（5分钟）
- 📤 上传本地数据
- 📥 下载服务器更新
- 🔄 冲突解决

**使用示例：**

```dart
// 初始化
await SyncService().initialize();

// 手动同步
await SyncService().manualSync();

// 获取未同步数量
final count = await SyncService().getUnsyncedCount();
```

#### 2. 数据标记策略

每条记录都有`synced`字段：

```dart
class RoadDefect {
  final bool synced;  // false=未同步, true=已同步
}
```

**状态流转：**
```
创建 → synced=false
  ↓
上传成功 → synced=true
  ↓
修改 → synced=false（再次需要同步）
```

## 🚀 实现细节

### 1. 网络监听

```dart
_connectivity.onConnectivityChanged.listen((results) {
  if (results.first != ConnectivityResult.none) {
    // 网络恢复，立即同步
    syncAllData();
  }
});
```

### 2. 定时同步

```dart
Timer.periodic(Duration(minutes: 5), (_) {
  syncAllData();
});
```

### 3. 上传策略

```dart
// 1. 获取未同步数据
final unsyncedDefects = box.values
    .where((d) => !d.synced)
    .toList();

// 2. 逐条上传
for (var defect in unsyncedDefects) {
  await _dio.post('/api/defects', data: defect.toJson());
  
  // 3. 标记已同步
  await box.put(defect.id, defect.copyWith(synced: true));
}
```

### 4. 下载策略

```dart
// 1. 获取服务器更新
final response = await _dio.get('/api/tasks/updates');

// 2. 对比本地数据
final serverTasks = response.data['tasks'];
for (var taskJson in serverTasks) {
  final exists = box.values.any((t) => t.id == taskJson['id']);
  
  if (!exists) {
    // 3. 下载新数据
    await box.add(parseTask(taskJson));
  }
}
```

## 🎯 使用场景

### 场景1：外业巡查（无网）

```
用户在野外巡查，没有网络
  ↓
拍照记录病害
  ↓
数据保存到本地Hive数据库（synced=false）
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
标记synced=true
  ↓
同步完成
```

### 场景3：实时协作

```
A用户创建任务（有网）
  ↓
上传到服务器
  ↓
B用户打开APP（有网）
  ↓
SyncService自动下载新任务
  ↓
B用户看到新任务
```

## 💡 最佳实践

### 1. 冲突处理

**策略：服务器优先**

```dart
if (localVersion.updatedAt < serverVersion.updatedAt) {
  // 使用服务器版本
  await box.put(id, serverVersion);
} else {
  // 保留本地版本并上传
  await uploadToServer(localVersion);
}
```

### 2. 批量同步优化

```dart
// ❌ 错误：逐条同步
for (var item in items) {
  await uploadOne(item);  // 慢
}

// ✅ 正确：批量同步
await uploadBatch(items);  // 快
```

### 3. 失败重试

```dart
int retryCount = 0;
while (retryCount < 3) {
  try {
    await upload(data);
    break;
  } catch (e) {
    retryCount++;
    await Future.delayed(Duration(seconds: 2 * retryCount));
  }
}
```

## 🔧 配置同步服务

### main.dart中初始化

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化同步服务
  await SyncService().initialize();
  
  runApp(MyApp());
}
```

### 在首页显示同步状态

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SyncStatusWidget(),  // 同步状态提示
          // ... 其他内容
        ],
      ),
    );
  }
}
```

## 📊 数据流向图

```
用户设备                      服务器
   │                            │
   │  1. 离线创建数据            │
   │  (synced=false)           │
   │                            │
   │  2. 检测到网络              │
   ├──────────────────────────>│
   │  POST /api/defects        │
   │                            │
   │  3. 服务器保存              │
   │                      [数据库]
   │                            │
   │<──────────────────────────┤
   │  200 OK                   │
   │                            │
   │  4. 标记synced=true        │
   │                            │
   │  5. 定期拉取更新            │
   ├──────────────────────────>│
   │  GET /api/tasks/updates   │
   │                            │
   │<──────────────────────────┤
   │  {tasks: [...]}           │
   │                            │
   │  6. 更新本地数据            │
   │                            │
```

## ⚠️ 注意事项

1. **网络权限**
   - Android：自动包含
   - iOS：需配置网络使用说明

2. **存储空间**
   - 监控本地数据库大小
   - 定期清理已同步的旧数据

3. **电量消耗**
   - 在WiFi环境下优先同步
   - 低电量时降低同步频率

4. **数据安全**
   - 上传前加密敏感数据
   - 使用HTTPS传输

## 🆚 PWA对比

### PWA Service Worker示例

```javascript
// PWA的离线缓存（仅供对比）
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => response || fetch(event.request))
  );
});
```

**PWA的限制：**
- ❌ 浏览器关闭后无法后台同步
- ❌ 存储容量有限
- ❌ 权限受限
- ✅ 但跨平台性好

**移动应用的优势：**
- ✅ 真正的后台服务
- ✅ 无限存储空间
- ✅ 完整的系统权限
- ✅ 更好的性能

## 总结

本项目使用的是**原生移动应用的离线同步机制**，而非PWA：

| 对比项 | 移动应用 | PWA |
|-------|---------|-----|
| 技术 | Hive + 后台服务 | Service Worker |
| 适用场景 | 企业应用、外业工作 | 轻量级应用 |
| 离线能力 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| 同步能力 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |

选择移动应用方案是因为公路养护场景需要：
1. 长时间外业工作
2. 大量照片存储
3. 可靠的后台同步
4. 完整的设备权限
