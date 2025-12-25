class AppConfig {
  static const String appName = '公路养护';
  
  // API配置
  static const String apiBaseUrl = 'https://api.example.com/v1';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // Mock模式开关
  // true: 使用Mock数据（前端独立开发）
  // false: 使用真实API（后端完成后）
  static const bool useMockApi = true;  // ⚠️ 后端完成后改为false
  
  // Token存储（从SharedPreferences读取）
  static String? token;
  
  /// 设置Token
  static void setToken(String? newToken) {
    token = newToken;
  }
  
  /// 清除Token
  static void clearToken() {
    token = null;
  }
}
