/// Hasil pemeriksaan endpoint `GET /health`.
///
/// Field mengikuti respons backend yang terverifikasi:
/// `{"status": ..., "application": ..., "environment": ...}`.
/// Parsing tetap defensif: field yang tidak dikirim menjadi `null` dan tidak
/// ditampilkan di UI (tidak ada nilai yang dikarang).
class BackendHealth {
  const BackendHealth({
    required this.checkedAt,
    required this.latencyMs,
    this.status,
    this.application,
    this.environment,
  });

  /// Waktu pemeriksaan dilakukan di sisi aplikasi.
  final DateTime checkedAt;

  /// Durasi request dalam milidetik, diukur di sisi aplikasi.
  final int latencyMs;

  /// Nilai field `status` bila backend mengirimkannya.
  final String? status;

  /// Nama aplikasi backend bila dikirim (`application`).
  final String? application;

  /// Lingkungan backend bila dikirim (`environment`).
  final String? environment;

  static BackendHealth parse(
    Object? data, {
    required DateTime checkedAt,
    required int latencyMs,
  }) {
    if (data is! Map) {
      return BackendHealth(checkedAt: checkedAt, latencyMs: latencyMs);
    }
    return BackendHealth(
      checkedAt: checkedAt,
      latencyMs: latencyMs,
      status: _asText(data['status']),
      application: _asText(data['application']),
      environment: _asText(data['environment']),
    );
  }

  static String? _asText(Object? value) {
    if (value is String) {
      final String trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is bool) {
      return value ? 'true' : 'false';
    }
    if (value is num) {
      return value.toString();
    }
    return null;
  }

  @override
  String toString() =>
      'BackendHealth(status: $status, latencyMs: $latencyMs, checkedAt: $checkedAt)';
}
