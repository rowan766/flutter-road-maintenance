# 多语言支持（i18n）

## ✅ 已完成功能

### 1. 支持语言

- ✅ **简体中文** (zh)
- ✅ **English** (en)

### 2. 核心文件

| 文件 | 说明 |
|------|------|
| `lib/l10n/app_zh.arb` | 中文语言文件 |
| `lib/l10n/app_en.arb` | 英文语言文件 |
| `lib/core/providers/locale_provider.dart` | 语言管理Provider |
| `lib/features/settings/presentation/pages/settings_page.dart` | 设置页面（语言切换） |
| `l10n.yaml` | l10n配置 |

---

## 🚀 快速开始

### 1. 生成多语言代码

```bash
# 运行flutter pub get后会自动生成
flutter pub get

# 或手动生成
flutter gen-l10n
```

生成的文件：`.dart_tool/flutter_gen/gen_l10n/`

### 2. 在代码中使用

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// 获取本地化对象
final l10n = AppLocalizations.of(context)!;

// 使用翻译文本
Text(l10n.appName)          // "公路养护" 或 "Road Maintenance"
Text(l10n.common_confirm)   // "确定" 或 "Confirm"
Text(l10n.home_inspection)  // "道路巡查" 或 "Road Inspection"
```

### 3. 切换语言

```dart
// 方法1：通过Provider
context.read<LocaleProvider>().setZh();  // 切换到中文
context.read<LocaleProvider>().setEn();  // 切换到英文

// 方法2：在设置页面选择
Navigator.pushNamed(context, '/settings');
```

---

## 📝 添加新的翻译

### 1. 在ARB文件中添加

**lib/l10n/app_zh.arb:**
```json
{
  "新的键": "中文翻译",
  "@新的键": {
    "description": "描述信息"
  }
}
```

**lib/l10n/app_en.arb:**
```json
{
  "新的键": "English Translation",
  "@新的键": {
    "description": "Description"
  }
}
```

### 2. 重新生成代码

```bash
flutter pub get
```

### 3. 使用新翻译

```dart
Text(l10n.新的键)
```

---

## 🌍 添加新语言

### 1. 创建新的ARB文件

```bash
lib/l10n/app_ja.arb  # 日语
lib/l10n/app_ko.arb  # 韩语
lib/l10n/app_fr.arb  # 法语
```

### 2. 复制已有翻译并修改

复制 `app_zh.arb` 的内容，修改 `@@locale` 和翻译文本：

```json
{
  "@@locale": "ja",
  "appName": "道路メンテナンス",
  ...
}
```

### 3. 更新支持的语言列表

**lib/main.dart:**
```dart
supportedLocales: const [
  Locale('zh'),
  Locale('en'),
  Locale('ja'), // 新增
],
```

### 4. 更新LocaleProvider（可选）

**lib/core/providers/locale_provider.dart:**
```dart
Future<void> setJa() async {
  await setLocale(const Locale('ja'));
}
```

---

## 💡 命名规范

### 键名格式

```
{模块}_{功能}_{具体内容}
```

### 示例

```json
{
  "common_confirm": "确定",        // 通用-确认
  "common_cancel": "取消",         // 通用-取消
  
  "auth_login": "登录",           // 认证-登录
  "auth_username": "用户名",      // 认证-用户名
  
  "home_inspection": "道路巡查",  // 首页-巡查
  "home_maintenance": "养护管理", // 首页-养护
  
  "defect_type_crack": "裂缝",    // 病害-类型-裂缝
  "defect_severity_minor": "轻微", // 病害-严重程度-轻微
  
  "task_status_pending": "待分配",  // 任务-状态-待分配
}
```

---

## 🔧 高级用法

### 1. 带参数的翻译

**app_zh.arb:**
```json
{
  "greeting": "你好，{name}！",
  "@greeting": {
    "description": "问候语",
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

**使用：**
```dart
Text(l10n.greeting('张三'))  // "你好，张三！"
```

### 2. 复数形式

**app_en.arb:**
```json
{
  "itemsCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",
  "@itemsCount": {
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}
```

### 3. 日期和数字格式化

```dart
import 'package:intl/intl.dart';

// 日期格式化
final date = DateTime.now();
final formatted = DateFormat.yMMMd(l10n.localeName).format(date);

// 数字格式化
final number = 12345.67;
final formatted = NumberFormat.currency(
  locale: l10n.localeName,
  symbol: '¥',
).format(number);
```

---

## 📊 完整翻译清单

### 通用 (common_*)
- ✅ 确定、取消、保存、删除、编辑
- ✅ 搜索、筛选、刷新
- ✅ 加载中、暂无数据、错误、成功、失败

### 认证 (auth_*)
- ✅ 登录、登出、用户名、密码
- ✅ 登录成功、登录失败

### 首页 (home_*)
- ✅ 道路巡查、病害记录、养护管理、统计报表
- ✅ 各功能子标题

### 巡查 (inspection_*)
- ✅ 开始巡查、结束巡查、巡查中
- ✅ 里程、时长、速度

### 病害 (defect_*)
- ✅ 病害类型、严重程度、详细描述
- ✅ 照片、位置信息、道路名称
- ✅ 类型：裂缝、坑槽、沉陷、松散、波浪、其他
- ✅ 程度：轻微、中等、严重

### 任务 (task_*)
- ✅ 任务标题、类型、优先级、状态
- ✅ 负责人、创建时间、完成时间
- ✅ 类型：日常养护、专项维修、应急抢修
- ✅ 优先级：低、中、高、紧急
- ✅ 状态：待分配、进行中、已完成、已验收

### 报表 (report_*)
- ✅ 数据概览、病害数量、任务总数
- ✅ 已完成、进行中
- ✅ 病害分布、任务分析、最近活动

### 同步 (sync_*)
- ✅ 同步中、立即同步、上次同步
- ✅ 待同步数据、同步成功、同步失败
- ✅ 无网络连接、自动同步提示

### 设置 (settings_*)
- ✅ 设置、语言、主题、关于

### 语言 (language_*)
- ✅ 简体中文、English

---

## 🌟 最佳实践

### 1. 保持键名一致性
- 所有ARB文件的键名必须完全相同
- 只有值（翻译）不同

### 2. 提供描述
```json
"@appName": {
  "description": "应用名称"
}
```

### 3. 避免硬编码文本
```dart
// ❌ 错误
Text('公路养护')

// ✅ 正确
Text(l10n.appName)
```

### 4. 语言包分离
- 不要在代码中混入翻译字符串
- 所有文本都在ARB文件中定义

### 5. 测试多语言
```dart
// 切换语言后测试所有页面
await context.read<LocaleProvider>().setEn();
// 检查UI是否正常显示
```

---

## ⚠️ 注意事项

### 1. 代码生成
- 修改ARB文件后必须运行 `flutter pub get`
- 生成的代码在 `.dart_tool/flutter_gen/`
- 不要手动编辑生成的代码

### 2. 性能优化
- 使用 `AppLocalizations.of(context)!` 获取
- 不要在build方法外缓存

### 3. 空值处理
```dart
// 如果context可能为null
final l10n = AppLocalizations.of(context);
if (l10n != null) {
  Text(l10n.appName)
}

// 或使用!（确保context不为null）
final l10n = AppLocalizations.of(context)!;
```

### 4. 热重载限制
- 修改ARB文件需要完全重启应用
- 热重载(Hot Reload)不会生效

---

## 📚 参考资源

- [Flutter国际化官方文档](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)
- [ARB文件格式](https://github.com/google/app-resource-bundle)
- [Intl package](https://pub.dev/packages/intl)

---

## ✨ 总结

### 已实现
✅ 中英文双语支持  
✅ 语言切换功能  
✅ 语言持久化存储  
✅ 完整翻译覆盖  
✅ 设置页面  

### 使用流程
1. 获取 `AppLocalizations` 对象
2. 使用 `l10n.键名` 获取翻译
3. 在设置中切换语言
4. 应用自动刷新

**多语言支持已完成！** 🎉
