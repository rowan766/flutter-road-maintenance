import 'package:flutter/material.dart';
import '../../core/platform/platform_detector.dart';
import '../../core/platform/platform_adapter.dart';

/// 平台适配示例页面
/// 展示如何使用PlatformDetector和PlatformAdapter
class PlatformExamplePage extends StatefulWidget {
  const PlatformExamplePage({super.key});

  @override
  State<PlatformExamplePage> createState() => _PlatformExamplePageState();
}

class _PlatformExamplePageState extends State<PlatformExamplePage> {
  final _adapter = PlatformAdapter();
  String _documentsPath = '';
  String _cachePath = '';
  Map<String, dynamic> _platformConfig = {};
  Map<String, double> _uiConfig = {};

  @override
  void initState() {
    super.initState();
    _loadPlatformInfo();
  }

  Future<void> _loadPlatformInfo() async {
    final docsPath = await _adapter.getDocumentsPath();
    final cachePath = await _adapter.getCachePath();
    final platformConfig = _adapter.getPlatformConfig();
    final uiConfig = _adapter.getUIConfig();

    setState(() {
      _documentsPath = docsPath;
      _cachePath = cachePath;
      _platformConfig = platformConfig;
      _uiConfig = uiConfig;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 使用平台适配的UI配置
    final borderRadius = _uiConfig['borderRadius'] ?? 8.0;
    final spacing = _uiConfig['spacing'] ?? 16.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('平台适配示例'),
      ),
      body: ListView(
        padding: EdgeInsets.all(spacing),
        children: [
          _buildPlatformInfoCard(borderRadius, spacing),
          SizedBox(height: spacing),
          _buildPathInfoCard(borderRadius, spacing),
          SizedBox(height: spacing),
          _buildConfigCard(borderRadius, spacing),
          SizedBox(height: spacing),
          _buildUIConfigCard(borderRadius, spacing),
          SizedBox(height: spacing),
          _buildExampleButtons(borderRadius, spacing),
        ],
      ),
    );
  }

  /// 平台信息卡片
  Widget _buildPlatformInfoCard(double borderRadius, double spacing) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎯 平台信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: spacing),
            _buildInfoRow('平台名称', PlatformDetector.platformName),
            _buildInfoRow('系统版本', PlatformDetector.osVersion),
            _buildInfoRow('是否移动端', PlatformDetector.isMobile.toString()),
            _buildInfoRow('是否桌面端', PlatformDetector.isDesktop.toString()),
            _buildInfoRow('是否Web', PlatformDetector.isWeb.toString()),
            SizedBox(height: spacing),
            // 平台标识
            Wrap(
              spacing: 8,
              children: [
                if (PlatformDetector.isAndroid)
                  _buildPlatformChip('Android', Colors.green),
                if (PlatformDetector.isIOS)
                  _buildPlatformChip('iOS', Colors.blue),
                if (PlatformDetector.isHarmonyOS)
                  _buildPlatformChip('HarmonyOS', Colors.orange),
                if (PlatformDetector.isWindows)
                  _buildPlatformChip('Windows', Colors.blue),
                if (PlatformDetector.isMacOS)
                  _buildPlatformChip('macOS', Colors.grey),
                if (PlatformDetector.isLinux)
                  _buildPlatformChip('Linux', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 路径信息卡片
  Widget _buildPathInfoCard(double borderRadius, double spacing) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📁 路径信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: spacing),
            _buildInfoRow('文档目录', _documentsPath),
            _buildInfoRow('缓存目录', _cachePath),
          ],
        ),
      ),
    );
  }

  /// 平台配置卡片
  Widget _buildConfigCard(double borderRadius, double spacing) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚙️ 平台配置',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: spacing),
            if (_platformConfig.isNotEmpty) ...[
              _buildInfoRow(
                '最大图片大小',
                '${(_platformConfig['maxImageSize'] / (1024 * 1024)).toStringAsFixed(1)}MB',
              ),
              _buildInfoRow(
                '压缩质量',
                '${_platformConfig['compressionQuality']}%',
              ),
              _buildInfoRow(
                '使用系统选择器',
                _platformConfig['useSystemPicker'].toString(),
              ),
              _buildInfoRow(
                '需要权限',
                _platformConfig['requiresPermission'].toString(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// UI配置卡片
  Widget _buildUIConfigCard(double borderRadius, double spacing) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎨 UI配置',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: spacing),
            if (_uiConfig.isNotEmpty) ...[
              _buildInfoRow('圆角半径', '${_uiConfig['borderRadius']}dp'),
              _buildInfoRow('阴影', '${_uiConfig['elevation']}'),
              _buildInfoRow('间距', '${_uiConfig['spacing']}dp'),
              _buildInfoRow('图标大小', '${_uiConfig['iconSize']}dp'),
            ],
            SizedBox(height: spacing),
            // 实际效果展示
            const Text('实际效果：', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: spacing / 2),
            Container(
              padding: EdgeInsets.all(spacing),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    size: _uiConfig['iconSize'],
                    color: Colors.blue,
                  ),
                  SizedBox(width: spacing),
                  const Expanded(
                    child: Text('这是一个使用平台适配UI的示例容器'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 示例按钮
  Widget _buildExampleButtons(double borderRadius, double spacing) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🧪 功能示例',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: spacing),
            ElevatedButton.icon(
              onPressed: () {
                PlatformDetector.printInfo();
                _adapter.printAdapterInfo();
              },
              icon: const Icon(Icons.print),
              label: const Text('打印平台信息到控制台'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ),
            SizedBox(height: spacing / 2),
            ElevatedButton.icon(
              onPressed: _showPlatformDialog,
              icon: const Icon(Icons.info),
              label: const Text('显示平台特定对话框'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  /// 平台标识
  Widget _buildPlatformChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  /// 显示平台特定对话框
  void _showPlatformDialog() {
    final borderRadius = _uiConfig['borderRadius'] ?? 8.0;

    String message;
    if (PlatformDetector.isHarmonyOS) {
      message = '您正在使用HarmonyOS设备！\n\n'
          '• 支持System Picker无需权限\n'
          '• 推荐使用大圆角设计\n'
          '• 最大图片支持10MB';
    } else if (PlatformDetector.isAndroid) {
      message = '您正在使用Android设备！\n\n'
          '• Material Design规范\n'
          '• 需要运行时权限\n'
          '• 推荐图片5MB以内';
    } else if (PlatformDetector.isIOS) {
      message = '您正在使用iOS设备！\n\n'
          '• iOS设计规范\n'
          '• 需要Info.plist权限\n'
          '• 推荐图片5MB以内';
    } else {
      message = '当前平台: ${PlatformDetector.platformName}';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        title: const Text('平台检测'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
