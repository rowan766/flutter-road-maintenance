# 服务端API对接指南

## 📋 目录
- [方案说明](#方案说明)
- [前端准备工作](#前端准备工作)
- [Mock开发模式](#mock开发模式)
- [切换到真实API](#切换到真实api)
- [接口对接checklist](#接口对接checklist)

---

## 方案说明

### ❓ 需要后台先写出来接口才能对接吗？

**答案：不需要！** 我们使用 **Mock + 接口规范** 的方式实现前后端并行开发：

```
前端开发 ─┬─> Mock API服务（模拟数据）
          │   ↓
          │   前端功能开发完成
          │   ↓
后端开发 ─┼─> 真实API完成
          │   ↓
          └─> 一行配置切换到真实API
```

### 🎯 优势

| 方式 | 优势 | 劣势 |
|------|------|------|
| **等后端完成** | 数据真实 | 前端等待时间长 |
| **Mock开发** | 前后端并行，不互相阻塞 | 需要约定接口规范 |

---

## 前端准备工作

### 1️⃣ 已完成的文件

```
lib/core/
├── config/
│   └── app_config.dart          # API配置（Mock开关）
├── services/
│   ├── mock_api_service.dart    # Mock服务
│   ├── real_api_service.dart    # 真实API服务
│   ├── api_service_factory.dart # 工厂（自动切换）
│   └── sync_service.dart        # 同步服务
docs/
└── API_SPEC.md                  # 接口规范文档
```

### 2️⃣ 核心配置

**lib/core/config/app_config.dart**
```dart
class AppConfig {
  // Mock模式开关
  static const bool useMockApi = true;  // 开发阶段
  // static const bool useMockApi = false; // 后端完成后
  
  // API地址
  static const String apiBaseUrl = 'https://api.example.com/v1';
}
```

---

## Mock开发模式

### 📝 接口规范已约定

文档位置：`docs/API_SPEC.md`

包含所有接口的：
- URL路径
- 请求方法
- 参数格式
- 返回数据结构
- 错误码说明

### 🔧 使用Mock API

**当前状态：** `useMockApi = true` ✅

```dart
// 在SyncService中自动使用Mock
final api = ApiServiceFactory.apiService;

// 上传病害 - 返回模拟数据
final response = await api.uploadDefect(defect);
// ✅ 成功返回: {code: 200, message: "success", data: {...}}
```

### 📦 Mock数据特点

```dart
MockApiService特性：
- ✅ 500ms模拟网络延迟
- ✅ 返回符合规范的数据结构
- ✅ 模拟成功/失败场景
- ✅ 自动生成ID和时间戳
```

### 💡 开发流程

```
1. 查看接口规范（API_SPEC.md）
   ↓
2. 使用Mock API开发前端功能
   ↓
3. 前端功能完成，UI/交互测试通过
   ↓
4. 等待后端完成
   ↓
5. 一行配置切换到真实API
```

---

## 切换到真实API

### 步骤1：后端完成接口

后端开发人员参考 `docs/API_SPEC.md` 实现接口

### 步骤2：修改配置（一行代码）

**lib/core/config/app_config.dart**
```dart
class AppConfig {
  // 改这一行即可！
  static const bool useMockApi = false; // 改为false
  
  // 修改为真实API地址
  static const String apiBaseUrl = 'https://your-api.com/v1';
}
```

### 步骤3：测试真实API

```bash
flutter run
```

所有接口自动切换到真实API！

---

## 接口对接Checklist

### 前端Checklist

- [x] API接口规范文档编写
- [x] Mock API服务实现
- [x] Real API服务实现
- [x] API工厂（自动切换）
- [x] 同步服务集成Mock
- [ ] **后端接口完成后切换配置**

### 后端Checklist

提供给后端开发人员：

- [ ] 参考 `docs/API_SPEC.md`
- [ ] 实现所有接口
- [ ] 接口测试通过
- [ ] 提供真实API地址
- [ ] 前后端联调

### 核心接口列表

| 优先级 | 接口 | 说明 |
|--------|------|------|
| 🔴 高 | POST /auth/login | 登录 |
| 🔴 高 | POST /defects | 上传病害 |
| 🔴 高 | POST /tasks/sync | 同步任务 |
| 🔴 高 | GET /tasks/updates | 获取任务更新 |
| 🟡 中 | POST /upload/photo | 上传照片 |
| 🟡 中 | GET /reports/overview | 概览数据 |
| 🟢 低 | GET /defects | 病害列表 |

---

## 实际对接示例

### 场景1：后端未完成（当前）

```dart
// app_config.dart
static const bool useMockApi = true; ✅

// 效果
api.uploadDefect(defect)
  ↓
MockApiService.uploadDefect()  // 模拟成功
  ↓
前端继续开发，不受阻塞 ✅
```

### 场景2：后端完成后

```dart
// app_config.dart
static const bool useMockApi = false; ✅
static const String apiBaseUrl = 'https://real-api.com/v1'; ✅

// 效果
api.uploadDefect(defect)
  ↓
RealApiService.uploadDefect()  // 调用真实API
  ↓
Dio发送HTTP请求到真实服务器 ✅
```

---

## 调试技巧

### 1. 查看当前使用的API

运行应用时查看控制台：

```
🔧 使用Mock API服务  // useMockApi = true
或
🌐 使用真实API服务  // useMockApi = false
```

### 2. 查看网络请求

Dio已配置日志拦截器：

```
I/flutter: ┌──── Request ────
I/flutter: POST /defects
I/flutter: Headers: {Authorization: Bearer xxx}
I/flutter: Body: {"id": "...", "type": "裂缝"}
I/flutter: 
I/flutter: ┌──── Response ────
I/flutter: {code: 200, message: "success"}
```

### 3. 模拟网络错误

在Mock中添加错误场景：

```dart
// mock_api_service.dart
Future<Response> uploadDefect(RoadDefect defect) async {
  await _delay();
  
  // 模拟网络错误
  if (defect.type == '测试错误') {
    throw DioException(
      requestOptions: RequestOptions(path: '/defects'),
      error: '网络连接失败',
    );
  }
  
  return Response(...);
}
```

---

## 常见问题

### Q1: Mock和Real的返回数据不一样怎么办？

**A:** 严格按照 `API_SPEC.md` 规范，Mock和Real返回相同结构：

```json
{
  "code": 200,
  "message": "success",
  "data": { ... }
}
```

### Q2: 后端接口地址变了怎么办？

**A:** 只需修改 `app_config.dart` 的 `apiBaseUrl`

### Q3: 部分接口用Mock，部分用Real？

**A:** 当前不支持。建议：
- 全部Mock（开发阶段）
- 全部Real（生产环境）

如需混合，可修改 `api_service_factory.dart`

### Q4: Mock数据不够真实？

**A:** 在 `mock_api_service.dart` 中丰富Mock数据：

```dart
// 返回更多样化的Mock数据
'data': {
  'tasks': [
    {'title': '道路清扫', ...},
    {'title': '井盖维修', ...},
    {'title': '路面修复', ...},
  ]
}
```

---

## 总结

### 当前状态

```
✅ 前端可独立开发
✅ Mock数据已就绪
✅ 接口规范已约定
⏳ 等待后端完成
```

### 后端完成后

```
1. 修改 useMockApi = false
2. 修改 apiBaseUrl = '真实地址'
3. 重新运行应用
4. 联调测试
5. ✅ 完成对接
```

**核心优势：前后端并行开发，互不阻塞！**
