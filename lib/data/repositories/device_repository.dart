import '../../core/constants/api_endpoints.dart';
import '../models/device_model.dart';
import '../models/device_state_model.dart';
import '../models/monitoring_model.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';

/// Repository untuk akses data perangkat dan monitoring.
///
/// Memakai [ApiClient] terpusat, tidak membuat Dio baru.
class DeviceRepository {
  DeviceRepository({required this.apiClient});

  final ApiClient apiClient;

  /// Ambil daftar perangkat dari backend.
  Future<DeviceListResponse> getDevices() async {
    final Map<String, dynamic> data = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.devices,
    );
    final DeviceListResponse? parsed = DeviceListResponse.tryParse(data);
    if (parsed == null) {
      throw const ApiException(
        kind: ApiExceptionKind.unexpected,
        message: 'Format respons daftar perangkat tidak sesuai.',
      );
    }
    return parsed;
  }

  /// Ambil detail perangkat tertentu.
  Future<Device?> getDevice(String logicalId) async {
    final Map<String, dynamic> data = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.device(logicalId),
    );
    return Device.tryParse(data);
  }

  /// Ambil status perangkat tertentu.
  Future<Device?> getDeviceStatus(String logicalId) async {
    final Map<String, dynamic> data = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.deviceStatusPath(logicalId),
    );
    return Device.tryParse(data);
  }

  /// Ambil kondisi perangkat tertentu, termasuk state kanal terbaru.
  ///
  /// Respons `null` berarti format respons tidak dikenali; pemanggil dapat
  /// menampilkannya sebagai data belum tersedia, bukan kondisi OFF.
  Future<DeviceStateSnapshot?> getDeviceState(String logicalId) async {
    final Map<String, dynamic> data = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.deviceStatePath(logicalId),
    );
    return DeviceStateSnapshot.tryParse(data);
  }

  /// Kirim perintah ke perangkat.
  Future<Map<String, dynamic>> sendCommand(
    String logicalId,
    Map<String, dynamic> command,
  ) {
    return apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.deviceCommandsPath(logicalId),
      data: command,
    );
  }

  /// Ambil status monitoring agregat.
  Future<MonitoringStatusResponse> getMonitoringStatus() async {
    final Map<String, dynamic> data = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.monitoringStatus,
    );
    return MonitoringStatusResponse.tryParse(data) ??
        const MonitoringStatusResponse(success: false, data: null);
  }

  /// Jalankan pemeriksaan monitoring manual.
  Future<MonitoringStatusResponse> checkMonitoring() async {
    final Map<String, dynamic> data = await apiClient
        .post<Map<String, dynamic>>(ApiEndpoints.monitoringCheck);
    return MonitoringStatusResponse.tryParse(data) ??
        const MonitoringStatusResponse(success: false, data: null);
  }
}
