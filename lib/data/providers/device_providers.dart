import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show immutable;

import '../models/device_model.dart';
import '../models/monitoring_model.dart';
import '../repositories/device_repository.dart';
import 'api_client_provider.dart';

/// Provider repository perangkat.
final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return DeviceRepository(apiClient: client);
});

/// State: daftar perangkat dan status loading/error.
@immutable
class DeviceListState {
  const DeviceListState({
    this.devices = const <Device>[],
    this.total = 0,
    this.isLoading = false,
    this.error,
    this.lastRefreshed,
  });

  final List<Device> devices;
  final int total;
  final bool isLoading;
  final Object? error;
  final DateTime? lastRefreshed;

  DeviceListState copyWith({
    List<Device>? devices,
    int? total,
    bool? isLoading,
    Object? error,
    DateTime? lastRefreshed,
    bool clearError = false,
  }) {
    return DeviceListState(
      devices: devices ?? this.devices,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
    );
  }

  @override
  String toString() {
    return 'DeviceListState(total: $total, devices: ${devices.length}, isLoading: $isLoading, error: $error)';
  }

  bool get isEmpty => devices.isEmpty;
  bool get isNotEmpty => devices.isNotEmpty;
  int get supportedDevices => total - unsupportedCount;
  int get unsupportedCount {
    return devices.where((d) => d.isVerificationRequired).length;
  }
}

/// Notifier untuk daftar perangkat.
class DeviceListNotifier extends Notifier<DeviceListState> {
  @override
  DeviceListState build() {
    Future<void>.microtask(load);
    return const DeviceListState();
  }

  Future<void> load() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repository = ref.read(deviceRepositoryProvider);
      final response = await repository.getDevices();
      state = state.copyWith(
        devices: response.devices,
        total: response.total,
        isLoading: false,
        lastRefreshed: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> refresh() async {
    await load();
  }

  Future<void> retry() async {
    state = state.copyWith(clearError: true);
    await load();
  }
}

/// Provider state daftar perangkat.
final deviceListProvider =
    NotifierProvider<DeviceListNotifier, DeviceListState>(
      DeviceListNotifier.new,
    );

/// State: detail perangkat tertentu.
@immutable
class DeviceDetailState {
  const DeviceDetailState({
    this.device,
    this.isLoading = false,
    this.error,
    this.lastRefreshed,
  });

  final Device? device;
  final bool isLoading;
  final Object? error;
  final DateTime? lastRefreshed;

  DeviceDetailState copyWith({
    Device? device,
    bool? isLoading,
    Object? error,
    DateTime? lastRefreshed,
    bool clearError = false,
  }) {
    return DeviceDetailState(
      device: device ?? this.device,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
    );
  }
}

/// Notifier untuk detail perangkat (satu instance per `logical_id`).
class DeviceDetailNotifier extends Notifier<DeviceDetailState> {
  DeviceDetailNotifier(this.logicalId);

  /// `logical_id` perangkat yang ditangani provider keluarga ini.
  final String logicalId;

  @override
  DeviceDetailState build() {
    Future<void>.microtask(() => load(logicalId));
    return const DeviceDetailState();
  }

  Future<void> load(String id) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repository = ref.read(deviceRepositoryProvider);
      final device = await repository.getDevice(id);
      if (device == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Perangkat tidak ditemukan pada respons backend.',
        );
        return;
      }
      state = state.copyWith(
        device: device,
        isLoading: false,
        lastRefreshed: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> refresh(String id) async {
    await load(id);
  }
}

/// Provider state detail perangkat.
final deviceDetailProvider =
    NotifierProvider.family<DeviceDetailNotifier, DeviceDetailState, String>(
      DeviceDetailNotifier.new,
    );

/// State gabungan perangkat dan monitoring.
@immutable
class DeviceAndMonitoringState {
  const DeviceAndMonitoringState({
    required this.deviceList,
    required this.monitoring,
    this.isLoading = false,
    this.error,
  });

  final DeviceListState deviceList;
  final MonitoringState monitoring;
  final bool isLoading;
  final Object? error;
}

final deviceAndMonitoringProvider = Provider<DeviceAndMonitoringState>((ref) {
  final deviceList = ref.watch(deviceListProvider);
  final monitoring = ref.watch(monitoringProvider);
  final isLoading = deviceList.isLoading || monitoring.isLoading;
  Object? error;
  if (deviceList.error != null) {
    error = deviceList.error;
  } else if (monitoring.error != null) {
    error = monitoring.error;
  }
  return DeviceAndMonitoringState(
    deviceList: deviceList,
    monitoring: monitoring,
    isLoading: isLoading,
    error: error,
  );
});

/// State: monitoring status.
@immutable
class MonitoringState {
  const MonitoringState({
    this.monitoring,
    this.isLoading = false,
    this.isChecking = false,
    this.error,
    this.lastRefreshed,
  });

  final MonitoringStatusResponse? monitoring;
  final bool isLoading;
  final bool isChecking;
  final Object? error;
  final DateTime? lastRefreshed;

  MonitoringState copyWith({
    MonitoringStatusResponse? monitoring,
    bool? isLoading,
    bool? isChecking,
    Object? error,
    DateTime? lastRefreshed,
    bool clearError = false,
  }) {
    return MonitoringState(
      monitoring: monitoring ?? this.monitoring,
      isLoading: isLoading ?? this.isLoading,
      isChecking: isChecking ?? this.isChecking,
      error: clearError ? null : (error ?? this.error),
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
    );
  }
}

/// Notifier untuk monitoring.
class MonitoringNotifier extends Notifier<MonitoringState> {
  @override
  MonitoringState build() {
    Future<void>.microtask(load);
    return const MonitoringState();
  }

  Future<void> load() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      isChecking: false,
      clearError: true,
    );
    try {
      final repository = ref.read(deviceRepositoryProvider);
      final response = await repository.getMonitoringStatus();
      state = state.copyWith(
        monitoring: response,
        isLoading: false,
        lastRefreshed: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> check() async {
    if (state.isChecking) return;

    state = state.copyWith(isChecking: true, clearError: true);
    try {
      final repository = ref.read(deviceRepositoryProvider);
      final response = await repository.checkMonitoring();
      state = state.copyWith(
        monitoring: response,
        isChecking: false,
        lastRefreshed: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(isChecking: false, error: e);
    }
  }

  Future<void> refresh() async {
    await load();
  }
}

/// Provider state monitoring.
final monitoringProvider =
    NotifierProvider<MonitoringNotifier, MonitoringState>(
      MonitoringNotifier.new,
    );
