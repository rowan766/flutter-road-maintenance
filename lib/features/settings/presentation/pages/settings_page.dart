import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';

/// 设置页面
/// 包含语言切换等设置选项
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings_title),
      ),
      body: ListView(
        children: [
          _buildLanguageSection(context, l10n),
          const Divider(),
          _buildAboutSection(context, l10n),
        ],
      ),
    );
  }

  /// 语言设置区域
  Widget _buildLanguageSection(BuildContext context, AppLocalizations l10n) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return ListTile(
          leading: const Icon(Icons.language),
          title: Text(l10n.settings_language),
          subtitle: Text(localeProvider.languageName),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLanguageDialog(context, l10n, localeProvider),
        );
      },
    );
  }

  /// 关于区域
  Widget _buildAboutSection(BuildContext context, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: Text(l10n.settings_about),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showAboutDialog(context, l10n),
    );
  }

  /// 显示语言选择对话框
  void _showLanguageDialog(
    BuildContext context,
    AppLocalizations l10n,
    LocaleProvider localeProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settings_language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(l10n.language_zh),
              value: 'zh',
              groupValue: localeProvider.locale.languageCode,
              onChanged: (value) {
                localeProvider.setZh();
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.language_en),
              value: 'en',
              groupValue: localeProvider.locale.languageCode,
              onChanged: (value) {
                localeProvider.setEn();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.common_cancel),
          ),
        ],
      ),
    );
  }

  /// 显示关于对话框
  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    showAboutDialog(
      context: context,
      applicationName: l10n.appName,
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Road Maintenance Team',
      children: [
        const SizedBox(height: 16),
        Text(l10n.appName),
        const Text('A multi-platform road maintenance management system'),
      ],
    );
  }
}
