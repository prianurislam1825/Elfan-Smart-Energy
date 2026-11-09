import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/app_config.dart';
import 'api_exception.dart';
import 'api_interceptors.dart';

/// Klien HTTP terpusat.
///
/// Tanggung jawab:
/// - satu konfigurasi Dio (base URL, timeout, header JSON),
/// - pemetaan `DioException` menjadi [ApiException],
/// - penolakan request jika konfigurasi base URL belum valid.
///
/// Belum ada endpoint, autentikasi, atau penyimpanan token yang
/// diimplementasikan. Widget tidak boleh memakai Dio langsung; gunakan
/// `apiClientProvider` atau repository di `lib/data/repositories`.
class ApiClient {
  ApiClient({
    required AppConfig config,
    Dio? dio,
    bool enableLogging = kDebugMode,
  }) : _config = config,
       _dio = dio ?? _createDio(config, enableLogging: enableLogging);

  final AppConfig _config;
  final Dio _dio;

  AppConfig get config => _config;

  /// Instance Dio yang sudah dikonfigurasi. Hanya untuk kebutuhan lanjutan
  /// (mis. WebSocket/signaling di phase berikutnya).
  Dio get dio => _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) {
    return _send<T>(
      () => _dio.get<T>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      ),
    );
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) {
    return _send<T>(
      () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      ),
    );
  }

  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) {
    return _send<T>(
      () => _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      ),
    );
  }

  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) {
    return _send<T>(
      () => _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      ),
    );
  }

  void close({bool force = false}) => _dio.close(force: force);

  Future<T> _send<T>(Future<Response<T>> Function() request) async {
    final String? problem = _config.apiBaseUrlValidationError;
    if (problem != null) {
      throw ApiException(
        kind: ApiExceptionKind.configuration,
        message: problem,
      );
    }

    try {
      final Response<T> response = await request();
      final T? data = response.data;
      if (data == null) {
        throw ApiException(
          kind: ApiExceptionKind.unexpected,
          message: 'Respons backend kosong.',
          statusCode: response.statusCode,
        );
      }
      return data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  static Dio _createDio(AppConfig config, {required bool enableLogging}) {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        sendTimeout: config.sendTimeout,
        responseType: ResponseType.json,
        contentType: Headers.jsonContentType,
        headers: const <String, String>{'Accept': Headers.jsonContentType},
        followRedirects: true,
      ),
    );
    if (enableLogging) {
      dio.interceptors.add(ApiLoggingInterceptor());
    }
    return dio;
  }
}
