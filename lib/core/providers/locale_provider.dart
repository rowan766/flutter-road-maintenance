import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';

/// 语言管理Provider
/// 管理应用的语言切换和持久化
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  
  Locale _locale = const Locale('zh'); // 默认中文
  
  Locale get locale => _locale;
  
  /// 初始化语言设置（从本地存储读取）
  Future<void> loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_localeKey);
      
      if (languageCode != null) {
        _locale = Locale(languageCode);
        notifyListeners();
      }
    } catch (e) {
      print('加载语言设置失败: $e');
    }
  }
  
  /// 切换语言
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      print('保存语言设置失败: $e');
    }
  }
  
  /// 切换到中文
  Future<void> setZh() async {
    await setLocale(const Locale('zh'));
  }
  
  /// 切换到英文
  Future<void> setEn() async {
    await setLocale(const Locale('en'));
  }
  
  /// 获取当前语言名称
  String get languageName {
    switch (_locale.languageCode) {
      case 'zh':
        return '简体中文';
      case 'en':
        return 'English';
      default:
        return 'Unknown';
    }
  }
  
  /// 是否为中文
  bool get isZh => _locale.languageCode == 'zh';
  
  /// 是否为英文
  bool get isEn => _locale.languageCode == 'en';
}
