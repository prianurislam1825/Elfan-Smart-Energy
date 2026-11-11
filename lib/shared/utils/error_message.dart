import '../../data/services/api_exception.dart';

/// Pesan siap tampil untuk kegagalan API.
///
/// Satu tempat untuk seluruh layar agar pesan error konsisten dan tidak lagi
/// ditebak dari `toString()` exception.
String describeApiError(
  Object? error, {
  String fallback = 'Terjadi kesalahan. Coba lagi.',
}) {
  if (error is ApiException) {
    // Untuk kegagalan yang dibuat di sisi klien (mis. kontrol tidak didukung),
    // `message` sudah spesifik untuk pengguna.
    if (error.kind == ApiExceptionKind.unsupported) {
      return error.message;
    }
    return error.userMessage;
  }
  if (error is String && error.trim().isNotEmpty) {
    return error.trim();
  }
  return fallback;
}
