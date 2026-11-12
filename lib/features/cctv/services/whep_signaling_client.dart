import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../data/services/api_exception.dart';
import 'cctv_diagnostics.dart';

/// Sesi WHEP yang sudah dinegosiasikan dengan MediaMTX.
class WhepSession {
  const WhepSession({required this.answerSdp, this.resourceUri});

  /// SDP answer dari media server.
  final String answerSdp;

  /// URL resource sesi (`Location` header) untuk menutup sesi di server.
  final Uri? resourceUri;
}

/// Kontrak signaling WHEP agar player dapat diuji tanpa jaringan.
abstract interface class CctvSignaling {
  /// Kirim SDP offer dan terima SDP answer.
  Future<WhepSession> connect({required Uri whepUrl, required String offerSdp});

  /// Tutup sesi di media server (best effort).
  Future<void> disconnect(WhepSession session);
}

/// Klien signaling WHEP MediaMTX.
///
/// Sengaja tidak memakai [ApiClient] karena `whep_url` berasal dari MediaMTX,
/// bukan dari base URL FastAPI. Alamatnya selalu diberikan backend melalui
/// `GET /api/v1/cctv/cameras/{id}/stream`; tidak ada URL yang di-hardcode di
/// sini maupun di layar CCTV.
class WhepSignalingClient implements CctvSignaling {
  WhepSignalingClient({required AppConfig config, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: config.connectTimeout,
              receiveTimeout: config.receiveTimeout,
              sendTimeout: config.sendTimeout,
              responseType: ResponseType.plain,
            ),
          );

  final Dio _dio;

  static const String _sdpContentType = 'application/sdp';

  @override
  Future<WhepSession> connect({
    required Uri whepUrl,
    required String offerSdp,
  }) async {
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        whepUrl.toString(),
        data: offerSdp,
        options: Options(
          contentType: _sdpContentType,
          responseType: ResponseType.plain,
          headers: const <String, String>{'Accept': _sdpContentType},
        ),
      );

      CctvDiagnostics.log(
        CctvDiagnostics.whepTag,
        'POST ${CctvDiagnostics.safeUrl(whepUrl)} → ${response.statusCode} '
        'contentType=${response.headers.value('content-type')} '
        'location=${response.headers.value('location')}',
      );

      final Object? body = response.data;
      final String answer = _normalizeAnswer(body);
      CctvDiagnostics.log(
        CctvDiagnostics.whepTag,
        'answer ${CctvDiagnostics.describeSdp(answer)}',
      );
      if (!answer.contains('v=0')) {
        throw const ApiException(
          kind: ApiExceptionKind.unexpected,
          message: 'Media server mengirim jawaban SDP yang tidak valid.',
        );
      }

      return WhepSession(
        answerSdp: answer,
        resourceUri: _resolveLocation(
          response.headers.value('location'),
          whepUrl,
        ),
      );
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<void> disconnect(WhepSession session) async {
    final Uri? resource = session.resourceUri;
    if (resource == null) {
      return;
    }
    try {
      await _dio.delete<dynamic>(
        resource.toString(),
        options: Options(
          responseType: ResponseType.plain,
          receiveTimeout: const Duration(seconds: 2),
        ),
      );
    } on DioException {
      // Sesi server bisa saja sudah berakhir; kegagalan menutup sesi tidak
      // boleh menutupi hasil pemutaran atau menggagalkan reconnect.
    }
  }

  /// SDP answer harus dipertahankan apa adanya.
  ///
  /// `String.trim()` menghapus `\r\n` penutup SDP. libwebrtc di Android
  /// menolak SDP tanpa baris penutup tersebut dengan
  /// `WEBRTC_SET_REMOTE_DESCRIPTION_ERROR: SessionDescription is NULL.`,
  /// sehingga stream tidak pernah tersambung. Karena itu hanya ditambahkan
  /// penutup baris bila media server tidak mengirimkannya.
  static String _normalizeAnswer(Object? body) {
    if (body is! String || body.isEmpty) {
      return '';
    }
    if (body.endsWith('\n')) {
      return body;
    }
    return '$body\r\n';
  }

  Uri? _resolveLocation(String? location, Uri whepUrl) {
    if (location == null || location.trim().isEmpty) {
      return null;
    }
    final Uri? parsed = Uri.tryParse(location.trim());
    if (parsed == null) {
      return null;
    }
    return parsed.hasScheme ? parsed : whepUrl.resolveUri(parsed);
  }

  ApiException _mapError(DioException error) {
    final ApiException base = ApiException.fromDio(error);
    return switch (base.kind) {
      ApiExceptionKind.timeout => const ApiException(
        kind: ApiExceptionKind.timeout,
        message: 'Media server CCTV tidak merespons tepat waktu.',
      ),
      ApiExceptionKind.connection => const ApiException(
        kind: ApiExceptionKind.connection,
        message:
            'Tidak dapat terhubung ke media server CCTV. Pastikan MediaMTX '
            'dapat dijangkau dari perangkat ini.',
      ),
      ApiExceptionKind.badRequest ||
      ApiExceptionKind.unauthorized ||
      ApiExceptionKind.forbidden ||
      ApiExceptionKind.notFound ||
      ApiExceptionKind.conflict ||
      ApiExceptionKind.validation ||
      ApiExceptionKind.server => ApiException(
        kind: base.kind,
        message:
            'Media server menolak permintaan stream (HTTP '
            '${base.statusCode ?? 'tidak diketahui'}).',
        statusCode: base.statusCode,
      ),
      _ => base,
    };
  }
}
