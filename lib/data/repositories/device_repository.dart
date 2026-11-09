import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../models/device_model.dart';
import '../models/monitoring_model.dart';

/// Repository untuk akses data perangkat dan monitoring.
///
/// Menggunakan ApiClient yang disediakan, tidak membuat Dio baru.
class DeviceRepository {
  DeviceRepository({required this.apiClient});

  final ApiClient apiClient;

  /// Ambil daftar perangkat dari backend.
  Future<DeviceListResponse> getDevices() async {
    final Map<String, dynamic> data =
        await apiClient.get<Map<String, dynamic>>(ApiEndpoints.devices);
    return DeviceListResponse.tryParse(data) ??
        DeviceListResponse(total: 0, devices: <Device>[]);
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

  /// Kirim perintah ke perangkat.
  Future<Map<String, dynamic>> sendCommand(
    String logicalId,
    Map<String, dynamic> command,
  ) async {
    return await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.deviceCommandsPath(logicalId),
      data: command,
    );
  }

  /// Ambil status monitoring agregat.
  Future<MonitoringStatusResponse> getMonitoringStatus() async {
    final Map<String, dynamic> data =
        await apiClient.get<Map<String, dynamic>>(ApiEndpoints.monitoringStatus);
    return MonitoringStatusResponse.tryParse(data) ??
        MonitoringStatusResponse(success: false, data: null);
  }

  /// Jalankan pemeriksaan monitoring manual.
  Future<MonitoringStatusResponse> checkMonitoring() async {
    final Map<String, dynamic> data =
        await apiClient.post<Map<String, dynamic>>(ApiEndpoints.monitoringCheck);
    return MonitoringStatusResponse.tryParse(data) ??
        MonitoringStatusResponse(success: false, data: null);
  }
}
