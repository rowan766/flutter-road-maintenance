# 公路养护移动应用

基于Flutter的多平台公路养护管理系统

## 平台支持
- Android
- iOS  
- HarmonyOS

## 项目结构

```
lib/
├── core/                   # 核心模块
│   ├── config/            # 配置文件
│   ├── theme/             # 主题
│   └── routes/            # 路由
├── features/              # 功能模块
│   ├── auth/             # 认证
│   ├── inspection/       # 巡查
│   ├── maintenance/      # 养护
│   └── report/           # 报表
├── shared/               # 共享组件
│   └── widgets/          # 通用组件
└── main.dart             # 入口文件
```

## 快速开始

```bash
# 安装依赖
flutter pub get

# 运行
flutter run

# 构建
flutter build apk          # Android
flutter build ios          # iOS
```

## 开发计划

- [x] 项目结构搭建
- [ ] 用户认证
- [ ] 地图集成
- [ ] 病害记录
- [ ] 任务管理
- [ ] 统计报表
- [ ] HarmonyOS适配
