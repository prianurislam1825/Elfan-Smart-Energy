import 'package:dio/dio.dart';
import 'package:elfan_mobile/core/config/app_config.dart';
import 'package:elfan_mobile/data/services/api_client.dart';
import 'package:elfan_mobile/data/services/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    test('menandai base URL kosong sebagai belum terkonfigurasi', () {
      const AppConfig config = AppConfig(apiBaseUrl: '');
      expect(config.hasApiBaseUrl, isFalse);
      expect(config.isApiConfigured, isFalse);
      expect(config.apiBaseUrlValidationError, isNotNull);
    });

    test('menerima base URL absolut http/https', () {
      const AppConfig config = AppConfig(
        apiBaseUrl: 'https://api.example.test',
      );
      expect(config.isApiConfigured, isTrue);
      expect(config.apiHost, 'api.example.test');
    });

    test('menolak skema selain http dan https', () {
      const AppConfig config = AppConfig(apiBaseUrl: 'ftp://api.example.test');
      expect(config.isApiConfigured, isFalse);
    });
  });

  group('ApiClient', () {
    test('tidak mengirim request saat base URL belum dikonfigurasi', () async {
      final Dio dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
      int requestCount = 0;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
                requestCount++;
                handler.next(options);
              },
        ),
      );

      final ApiClient client = ApiClient(
        config: const AppConfig(apiBaseUrl: ''),
        dio: dio,
      );
      addTearDown(client.close);

      await expectLater(
        client.get<Map<String, dynamic>>('/api/v1/devices'),
        throwsA(
          isA<ApiException>().having(
            (ApiException error) => error.kind,
            'kind',
            ApiExceptionKind.configuration,
          ),
        ),
      );
      expect(requestCount, 0);
    });
  });

  group('ApiException.fromDio', () {
    test('memetakan timeout sebagai kegagalan sementara', () {
      final DioException error = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.receiveTimeout,
      );

      final ApiException exception = ApiException.fromDio(error);
      expect(exception.kind, ApiExceptionKind.timeout);
      expect(exception.isTransient, isTrue);
    });

    test('memetakan connection error', () {
      final DioException error = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      );

      expect(ApiException.fromDio(error).kind, ApiExceptionKind.connection);
    });

    test('memetakan 401 dan membaca pesan teks dari body', () {
      final RequestOptions options = RequestOptions(path: '/x');
      final DioException error = DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: 401,
          data: <String, dynamic>{'detail': 'Token tidak valid'},
        ),
      );

      final ApiException exception = ApiException.fromDio(error);
      expect(exception.kind, ApiExceptionKind.unauthorized);
      expect(exception.statusCode, 401);
      expect(exception.message, 'Token tidak valid');
      expect(exception.isTransient, isFalse);
    });

    test('memetakan 422 tanpa menebak detail validasi berbentuk list', () {
      final RequestOptions options = RequestOptions(path: '/x');
      final DioException error = DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: 422,
          data: <String, dynamic>{
            'detail': <Map<String, dynamic>>[
              <String, dynamic>{
                'loc': <String>['body', 'name'],
                'msg': 'required',
              },
            ],
          },
        ),
      );

      final ApiException exception = ApiException.fromDio(error);
      expect(exception.kind, ApiExceptionKind.validation);
      expect(exception.message, 'Server mengembalikan status 422.');
    });

    test('memetakan 500 sebagai kegagalan server yang sementara', () {
      final RequestOptions options = RequestOptions(path: '/x');
      final DioException error = DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(requestOptions: options, statusCode: 500),
      );

      final ApiException exception = ApiException.fromDio(error);
      expect(exception.kind, ApiExceptionKind.server);
      expect(exception.isTransient, isTrue);
    });
  });
}
