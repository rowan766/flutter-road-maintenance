# API接口规范文档

## 基础信息

- **Base URL**: `https://api.example.com/v1`
- **认证方式**: Bearer Token
- **数据格式**: JSON
- **字符编码**: UTF-8

## 通用响应格式

### 成功响应
```json
{
  "code": 200,
  "message": "success",
  "data": { ... }
}
```

### 错误响应
```json
{
  "code": 400,
  "message": "错误信息",
  "data": null
}
```

## 接口列表

### 1. 用户认证

#### 1.1 登录
- **URL**: `/auth/login`
- **Method**: `POST`
- **Request**:
```json
{
  "username": "admin",
  "password": "123456"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "user": {
      "id": "user_001",
      "username": "admin",
      "avatar": "https://example.com/avatar.jpg"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### 1.2 登出
- **URL**: `/auth/logout`
- **Method**: `POST`
- **Headers**: `Authorization: Bearer {token}`
- **Response**:
```json
{
  "code": 200,
  "message": "success",
  "data": null
}
```

---

### 2. 病害管理

#### 2.1 上传病害记录
- **URL**: `/defects`
- **Method**: `POST`
- **Headers**: `Authorization: Bearer {token}`
- **Request**:
```json
{
  "id": "defect_001",
  "type": "裂缝",
  "severity": "中等",
  "description": "路面出现横向裂缝",
  "latitude": 39.9042,
  "longitude": 116.4074,
  "photos": [
    "/storage/photos/defect_001_1.jpg",
    "/storage/photos/defect_001_2.jpg"
  ],
  "roadName": "长安街",
  "createdAt": "2025-12-25T10:30:00Z"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "defect_001",
    "synced": true,
    "syncedAt": "2025-12-25T10:30:05Z"
  }
}
```

#### 2.2 批量上传病害
- **URL**: `/defects/batch`
- **Method**: `POST`
- **Headers**: `Authorization: Bearer {token}`
- **Request**:
```json
{
  "defects": [
    { "id": "defect_001", ... },
    { "id": "defect_002", ... }
  ]
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "success": ["defect_001", "defect_002"],
    "failed": []
  }
}
```

#### 2.3 获取病害列表
- **URL**: `/defects`
- **Method**: `GET`
- **Headers**: `Authorization: Bearer {token}`
- **Query Params**:
  - `page`: 页码（默认1）
  - `pageSize`: 每页数量（默认20）
  - `type`: 病害类型（可选）
  - `severity`: 严重程度（可选）
- **Response**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": 100,
    "page": 1,
    "pageSize": 20,
    "list": [
      {
        "id": "defect_001",
        "type": "裂缝",
        "severity": "中等",
        "description": "路面出现横向裂缝",
        "latitude": 39.9042,
        "longitude": 116.4074,
        "photos": ["url1", "url2"],
        "roadName": "长安街",
        "createdAt": "2025-12-25T10:30:00Z"
      }
    ]
  }
}
```

---

### 3. 任务管理

#### 3.1 同步任务数据
- **URL**: `/tasks/sync`
- **Method**: `POST`
- **Headers**: `Authorization: Bearer {token}`
- **Request**:
```json
{
  "tasks": [
    {
      "id": "task_001",
      "title": "修复路面裂缝",
      "description": "长安街段路面裂缝修复",
      "roadName": "长安街",
      "taskType": "专项维修",
      "status": "已完成",
      "priority": "高",
      "assignee": "张三",
      "createdAt": "2025-12-25T09:00:00Z",
      "completedAt": "2025-12-25T15:00:00Z"
    }
  ]
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "syncedCount": 1
  }
}
```

#### 3.2 获取任务更新
- **URL**: `/tasks/updates`
- **Method**: `GET`
- **Headers**: `Authorization: Bearer {token}`
- **Query Params**:
  - `lastSyncTime`: 上次同步时间（ISO格式）
- **Response**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "tasks": [
      {
        "id": "task_002",
        "title": "道路清扫",
        "description": "主干道日常清扫",
        "roadName": "建国路",
        "taskType": "日常养护",
        "status": "待分配",
        "priority": "中",
        "createdAt": "2025-12-25T14:00:00Z"
      }
    ]
  }
}
```

#### 3.3 创建任务
- **URL**: `/tasks`
- **Method**: `POST`
- **Headers**: `Authorization: Bearer {token}`
- **Request**:
```json
{
  "title": "道路清扫",
  "description": "主干道日常清扫",
  "roadName": "建国路",
  "taskType": "日常养护",
  "priority": "中"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "task_003",
    "title": "道路清扫",
    "status": "待分配",
    "createdAt": "2025-12-25T16:00:00Z"
  }
}
```

#### 3.4 更新任务状态
- **URL**: `/tasks/{taskId}/status`
- **Method**: `PUT`
- **Headers**: `Authorization: Bearer {token}`
- **Request**:
```json
{
  "status": "进行中",
  "assignee": "李四"
}
```
- **Response**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "task_003",
    "status": "进行中",
    "assignee": "李四",
    "updatedAt": "2025-12-25T16:30:00Z"
  }
}
```

---

### 4. 文件上传

#### 4.1 上传照片
- **URL**: `/upload/photo`
- **Method**: `POST`
- **Headers**: 
  - `Authorization: Bearer {token}`
  - `Content-Type: multipart/form-data`
- **Request**: FormData with file
- **Response**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "url": "https://cdn.example.com/photos/xxx.jpg",
    "filename": "defect_001_1.jpg",
    "size": 1024000
  }
}
```

#### 4.2 批量上传照片
- **URL**: `/upload/photos`
- **Method**: `POST`
- **Headers**: 
  - `Authorization: Bearer {token}`
  - `Content-Type: multipart/form-data`
- **Request**: FormData with multiple files
- **Response**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "urls": [
      "https://cdn.example.com/photos/xxx1.jpg",
      "https://cdn.example.com/photos/xxx2.jpg"
    ]
  }
}
```

---

### 5. 统计报表

#### 5.1 获取概览数据
- **URL**: `/reports/overview`
- **Method**: `GET`
- **Headers**: `Authorization: Bearer {token}`
- **Response**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "defectCount": 150,
    "taskCount": 80,
    "completedTaskCount": 60,
    "inProgressTaskCount": 15
  }
}
```

#### 5.2 病害类型统计
- **URL**: `/reports/defects/types`
- **Method**: `GET`
- **Headers**: `Authorization: Bearer {token}`
- **Response**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "裂缝": 45,
    "坑槽": 30,
    "沉陷": 20,
    "松散": 25,
    "波浪": 15,
    "其他": 15
  }
}
```

---

## 错误码说明

| Code | 说明 |
|------|------|
| 200 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未授权（token无效或过期） |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

## 认证流程

1. 客户端调用 `/auth/login` 获取token
2. 后续请求在Header中携带：`Authorization: Bearer {token}`
3. Token有效期：7天
4. Token过期后需重新登录

## 分页规范

所有列表接口都支持分页：
- **Query参数**：
  - `page`: 页码（从1开始）
  - `pageSize`: 每页数量（默认20，最大100）
- **Response格式**：
```json
{
  "total": 100,
  "page": 1,
  "pageSize": 20,
  "list": [...]
}
```

## 时间格式

统一使用ISO 8601格式：`2025-12-25T10:30:00Z`
