import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor logging yang aman.
///
/// Hanya mencatat method, path, status, dan durasi. Header, body, query string,
/// token, dan URL lengkap tidak pernah dicatat (AI_RULES §5 dan §Keamanan).
class ApiLoggingInterceptor extends Interceptor {
  ApiLoggingInterceptor({this.enabled = true});

  final bool enabled;
  static const String _tag = 'ApiClient';
  static const String _startedAtKey = 'elfan_request_started_at';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled) {
      options.extra[_startedAtKey] = DateTime.now().microsecondsSinceEpoch;
      debugPrint('[$_tag] → ${options.method} ${options.uri.path}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (enabled) {
      final RequestOptions request = response.requestOptions;
      debugPrint(
        '[$_tag] ← ${response.statusCode} ${request.method} '
        '${request.uri.path} (${_elapsedMs(request)} ms)',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enabled) {
      final RequestOptions request = err.requestOptions;
      debugPrint(
        '[$_tag] ✕ ${err.response?.statusCode ?? err.type.name} '
        '${request.method} ${request.uri.path} '
        '(${_elapsedMs(request)} ms, ${err.type.name})',
      );
    }
    handler.next(err);
  }

  int _elapsedMs(RequestOptions request) {
    final Object? startedAt = request.extra[_startedAtKey];
    if (startedAt is! int) {
      return 0;
    }
    return (DateTime.now().microsecondsSinceEpoch - startedAt) ~/ 1000;
  }
}
