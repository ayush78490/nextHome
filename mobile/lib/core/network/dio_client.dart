import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

/// Dio HTTP client provider with interceptors
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  dio.interceptors.addAll([
    _AuthInterceptor(ref),
    _LoggingInterceptor(),
    _ErrorInterceptor(),
  ]);

  return dio;
});

/// Auth interceptor – auto-attaches backend JWT
class _AuthInterceptor extends Interceptor {
  final Ref _ref;
  static const _storage = FlutterSecureStorage();

  _AuthInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Get backend JWT
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired or invalid
      // TODO: Handle logout or redirect to login
    }
    handler.next(err);
  }
}

/// Logging interceptor (dev only)
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    assert(() {
      // ignore: avoid_print
      print('→ [${options.method}] ${options.uri}');
      return true;
    }());
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    assert(() {
      // ignore: avoid_print
      print('← [${response.statusCode}] ${response.requestOptions.path}');
      return true;
    }());
    handler.next(response);
  }
}

/// Error interceptor – converts DioException to ApiException
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiErr = ApiException.fromDio(err);
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: apiErr,
      type: err.type,
      response: err.response,
    ));
  }
}

/// Typed API exception
class ApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;

  const ApiException({required this.code, required this.message, this.statusCode});

  factory ApiException.fromDio(DioException err) {
    final data = err.response?.data;
    if (data is Map<String, dynamic>) {
      return ApiException(
        code:       data['code']    as String? ?? 'UNKNOWN',
        message:    data['message'] as String? ?? 'An error occurred',
        statusCode: err.response?.statusCode,
      );
    }
    return ApiException(
      code:    'NETWORK_ERROR',
      message: err.message ?? 'Network error',
      statusCode: err.response?.statusCode,
    );
  }

  @override
  String toString() => 'ApiException($code): $message';
}
