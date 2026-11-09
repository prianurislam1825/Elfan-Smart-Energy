import 'package:flutter/foundation.dart';

/// Konfigurasi aplikasi non-rahasia.
///
/// Base URL tidak di-hardcode di kode UI maupun di repository. Nilainya
/// diberikan saat build/run:
///
/// ```bash
/// flutter run --dart-define=ELFAN_API_BASE_URL=https://api.example.com
/// ```
///
/// Alamat LAN backend (`192.168.20.137:8000`) adalah alamat development dan
/// sengaja tidak dijadikan default. Catatan: pada Android, HTTP cleartext ke
/// alamat LAN diblokir kebijakan platform sampai network security config
/// produksi/development ditetapkan (lihat CHANGELOG dan laporan Task 02).
@immutable
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 20),
    this.sendTimeout = const Duration(seconds: 30),
  });

  factory AppConfig.fromEnvironment() {
    return AppConfig(
      apiBaseUrl: _sanitizeBaseUrl(
        const String.fromEnvironment(apiBaseUrlDefine),
      ),
    );
  }

  /// Nama `--dart-define` untuk base URL API.
  static const String apiBaseUrlDefine = 'ELFAN_API_BASE_URL';

  final String apiBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  bool get hasApiBaseUrl => apiBaseUrl.isNotEmpty;

  bool get isApiConfigured => apiBaseUrlValidationError == null;

  /// Host/port API tanpa path. Aman ditampilkan karena bukan rahasia.
  String? get apiHost {
    final Uri? uri = Uri.tryParse(apiBaseUrl);
    if (uri == null || !uri.hasAuthority) {
      return null;
    }
    return uri.authority;
  }

  /// Penjelasan masalah konfigurasi, atau `null` jika valid.
  String? get apiBaseUrlValidationError {
    if (!hasApiBaseUrl) {
      return 'Base URL API belum ditetapkan.';
    }
    final Uri? uri = Uri.tryParse(apiBaseUrl);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Base URL API bukan URL absolut yang valid.';
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return 'Base URL API harus memakai skema http atau https.';
    }
    return null;
  }

  static String _sanitizeBaseUrl(String raw) {
    final String trimmed = raw.trim();
    if (trimmed.length > 1 && trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
