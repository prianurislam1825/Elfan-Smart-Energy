/// Bentuk error respons yang dibaca secara defensif.
///
/// Kontrak error backend belum diverifikasi, sehingga parser hanya menerima
/// `code`/`error` dan `message`/`detail` jika bertipe teks. Bentuk lain
/// (mis. `detail` berupa list validasi) diabaikan, bukan ditebak.
class ApiError {
  const ApiError({this.code, this.message, this.details});

  final String? code;
  final String? message;
  final Map<String, dynamic>? details;

  static ApiError? tryParse(Object? body) {
    if (body is! Map) {
      return null;
    }
    final Map<String, dynamic> map = body.map<String, dynamic>(
      (Object? key, Object? value) => MapEntry<String, dynamic>('$key', value),
    );

    final String? code = _asText(map['code']) ?? _asText(map['error']);
    final String? message = _asText(map['message']) ?? _asText(map['detail']);
    final Object? rawDetails = map['details'];
    final Map<String, dynamic>? details = rawDetails is Map
        ? rawDetails.map<String, dynamic>(
            (Object? key, Object? value) =>
                MapEntry<String, dynamic>('$key', value),
          )
        : null;

    if (code == null && message == null && details == null) {
      return null;
    }
    return ApiError(code: code, message: message, details: details);
  }

  static String? _asText(Object? value) {
    if (value is String) {
      final String trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }
}
