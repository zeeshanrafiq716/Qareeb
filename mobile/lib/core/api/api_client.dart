import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../config/app_config.dart';

class ApiClient {
  static String? _globalAuthToken;

  static void setGlobalToken(String? token) {
    _globalAuthToken = token;
  }

  static String? get globalAuthToken => _globalAuthToken;

  late final Dio _dio;

  ApiClient({String? baseUrl, String? authToken}) {
    final effectiveBaseUrl = baseUrl ?? AppConfig.baseUrl;
    final token = authToken ?? _globalAuthToken;
    final initialHeaders = <String, dynamic>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      initialHeaders['Authorization'] = 'Bearer $token';
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: effectiveBaseUrl,
        connectTimeout: const Duration(milliseconds: AppConfig.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeoutMs),
        headers: initialHeaders,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final effectiveToken = authToken ?? _globalAuthToken;
          if (effectiveToken != null &&
              effectiveToken.isNotEmpty &&
              !options.headers.containsKey('Authorization')) {
            options.headers['Authorization'] = 'Bearer $effectiveToken';
          }
          developer.log('--> ${options.method} ${options.uri}', name: 'ApiClient');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          developer.log('<-- ${response.statusCode} ${response.requestOptions.uri}', name: 'ApiClient');
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          developer.log('ERR [${error.response?.statusCode}] ${error.requestOptions.uri}: ${error.message}', name: 'ApiClient');
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  void setAuthToken(String? token) {
    setGlobalToken(token);
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
    AppConfig.baseUrl = newBaseUrl;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
