/// Path API yang tercatat pada dokumentasi proyek.
///
/// Endpoint telah diverifikasi dari dokumentasi proyek.
/// Endpoint lain yang tercantum di dokumentasi perlu diverifikasi
/// sebelum digunakan, terutama untuk operasi kontrol perangkat.
abstract final class ApiEndpoints {
  /// `GET` — informasi backend.
  static const String root = '/';

  /// `GET` — health check.
  static const String health = '/health';

  /// `GET` — status koneksi Tuya.
  static const String tuyaConnection = '/api/v1/tuya/connection';

  /// `GET` — daftar perangkat.
  static const String devices = '/api/v1/devices';

  /// `GET` — detail perangkat.
  static const String deviceDetail = '/api/v1/devices/{logical_id}';

  /// `GET` — status perangkat.
  static const String deviceStatus = '/api/v1/devices/{logical_id}/status';

  /// `GET` — kondisi perangkat.
  static const String deviceState = '/api/v1/devices/{logical_id}/state';

  /// `POST` — kontrol perangkat.
  static const String deviceCommands = '/api/v1/devices/{logical_id}/commands';

  /// `GET` — status monitoring.
  static const String monitoringStatus = '/api/v1/monitoring/status';

  /// `POST` — pemeriksaan monitoring.
  static const String monitoringCheck = '/api/v1/monitoring/check';

  static String device(String logicalId) => '/api/v1/devices/$logicalId';
  static String deviceStatusPath(String logicalId) =>
      '/api/v1/devices/$logicalId/status';
  static String deviceStatePath(String logicalId) =>
      '/api/v1/devices/$logicalId/state';
  static String deviceCommandsPath(String logicalId) =>
      '/api/v1/devices/$logicalId/commands';
}
