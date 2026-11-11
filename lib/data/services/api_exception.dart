import 'package:dio/dio.dart';

import '../models/api_error.dart';

/// Jenis kegagalan API yang dipakai lapisan presentasi.
enum ApiExceptionKind {
  configuration,
  timeout,
  connection,
  cancelled,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  validation,
  server,
  unsupported,
  unexpected,
}

/// Exception terpusat untuk seluruh pemanggilan API.
class ApiException implements Exception {
  const ApiException({
    required this.kind,
    required this.message,
    this.statusCode,
    this.code,
    this.details,
  });

  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiException(
          kind: ApiExceptionKind.timeout,
          message: 'Permintaan melebihi batas waktu.',
          details: error.error,
        );
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
        return ApiException(
          kind: ApiExceptionKind.connection,
          message: 'Tidak dapat terhubung ke server.',
          details: error.error,
        );
      case DioExceptionType.cancel:
        return const ApiException(
          kind: ApiExceptionKind.cancelled,
          message: 'Permintaan dibatalkan.',
        );
      case DioExceptionType.badResponse:
        final int? status = error.response?.statusCode;
        final ApiError? body = ApiError.tryParse(error.response?.data);
        return ApiException(
          kind: kindForStatus(status),
          message: body?.message ?? 'Server mengembalikan status $status.',
          statusCode: status,
          code: body?.code,
          details: body?.details,
        );
      case DioExceptionType.unknown:
        return ApiException(
          kind: ApiExceptionKind.unexpected,
          message: 'Terjadi kesalahan tak terduga.',
          details: error.error,
        );
    }
  }

  final ApiExceptionKind kind;
  final String message;
  final int? statusCode;
  final String? code;
  final Object? details;

  static ApiExceptionKind kindForStatus(int? status) {
    if (status == null) {
      return ApiExceptionKind.unexpected;
    }
    return switch (status) {
      400 => ApiExceptionKind.badRequest,
      401 => ApiExceptionKind.unauthorized,
      403 => ApiExceptionKind.forbidden,
      404 => ApiExceptionKind.notFound,
      409 => ApiExceptionKind.conflict,
      422 => ApiExceptionKind.validation,
      >= 500 => ApiExceptionKind.server,
      _ => ApiExceptionKind.badRequest,
    };
  }

  /// Apakah kegagalan bersifat sementara sehingga layak dicoba ulang.
  ///
  /// Tidak dipakai untuk operasi kontrol perangkat (docs/02 §7: jangan retry
  /// kontrol secara buta).
  bool get isTransient =>
      kind == ApiExceptionKind.timeout ||
      kind == ApiExceptionKind.connection ||
      kind == ApiExceptionKind.server;

  /// Pesan siap tampil untuk pengguna.
  String get userMessage => switch (kind) {
    ApiExceptionKind.configuration =>
      'Konfigurasi API belum siap. Hubungi administrator aplikasi.',
    ApiExceptionKind.timeout =>
      'Server tidak merespons tepat waktu. Coba lagi.',
    ApiExceptionKind.connection =>
      'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
    ApiExceptionKind.cancelled => 'Permintaan dibatalkan.',
    ApiExceptionKind.unauthorized => 'Sesi tidak valid. Silakan masuk kembali.',
    ApiExceptionKind.forbidden => 'Anda tidak memiliki akses ke data ini.',
    ApiExceptionKind.notFound => 'Data yang diminta tidak ditemukan.',
    ApiExceptionKind.conflict => 'Permintaan bertentangan dengan data terbaru.',
    ApiExceptionKind.validation => 'Data yang dikirim tidak valid.',
    ApiExceptionKind.server => 'Server mengalami gangguan. Coba lagi nanti.',
    ApiExceptionKind.unsupported =>
      'Aksi ini belum didukung oleh perangkat atau backend.',
    ApiExceptionKind.badRequest => 'Permintaan tidak dapat diproses.',
    ApiExceptionKind.unexpected => 'Terjadi kesalahan tak terduga.',
  };

  @override
  String toString() {
    final String status = statusCode == null ? '' : ', statusCode: $statusCode';
    return 'ApiException(kind: ${kind.name}$status, message: $message)';
  }
}
