import 'package:dio/dio.dart';
import 'mock_api_service.dart';
import 'real_api_service.dart';
import '../config/app_config.dart';

/// API服务工厂
/// 用于在Mock和Real API之间切换
class ApiServiceFactory {
  static Dio? _dio;
  static dynamic _apiService;

  /// 获取Dio实例
  static Dio get dio {
    if (_dio == null) {
      _dio = Dio(BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ));

      // 添加拦截器
      _dio!.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));

      _dio!.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          // 自动添加Token
          final token = AppConfig.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // 统一错误处理
          if (error.response?.statusCode == 401) {
            // Token过期，跳转登录
            print('Token过期，请重新登录');
          }
          handler.next(error);
        },
      ));
    }
    return _dio!;
  }

  /// 获取API服务
  /// 根据配置返回Mock或Real服务
  static dynamic get apiService {
    if (_apiService == null) {
      if (AppConfig.useMockApi) {
        print('🔧 使用Mock API服务');
        _apiService = MockApiService(dio);
      } else {
        print('🌐 使用真实API服务');
        _apiService = RealApiService(dio);
      }
    }
    return _apiService;
  }

  /// 重置服务（用于切换Mock/Real）
  static void reset() {
    _apiService = null;
    _dio = null;
  }
}
