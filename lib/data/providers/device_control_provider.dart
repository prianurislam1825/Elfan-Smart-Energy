import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show immutable;

import 'device_providers.dart';
import '../models/device_model.dart';
import '../models/monitoring_model.dart';
import '../services/api_exception.dart';

/// Parameter kontrol perangkat.
class DeviceCommand {
  const DeviceCommand({
    required this.deviceId,
    required this.dpCode,
    required this.value,
    this.channelIndex,
  });

  final String deviceId;
  final String dpCode;
  final dynamic value;
  final int? channelIndex;
}

/// State kontrol perangkat.
@immutable
class DeviceControlState {
  const DeviceControlState({
    this.isControlling = false,
    this.pendingCommand,
    this.lastResult,
    this.error,
  });

  final bool isControlling;
  final DeviceCommand? pendingCommand;
  final Map<String, dynamic>? lastResult;
  final Object? error;

  DeviceControlState copyWith({
    bool? isControlling,
    DeviceCommand? pendingCommand,
    Map<String, dynamic>? lastResult,
    Object? error,
    bool clearError = false,
    bool clearPending = false,
  }) {
    return DeviceControlState(
      isControlling: isControlling ?? this.isControlling,
      pendingCommand: clearPending
          ? null
          : (pendingCommand ?? this.pendingCommand),
      lastResult: lastResult ?? this.lastResult,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Notifier untuk kontrol perangkat.
class DeviceControlNotifier extends Notifier<DeviceControlState> {
  @override
  DeviceControlState build() {
    return const DeviceControlState();
  }

  /// Kirim perintah ON ke perangkat.
  Future<void> turnOn(Device device) async {
    if (device.isMultiChannel) {
      await turnAllOn(device);
      return;
    }
    await _sendCommand(device.id, <String, dynamic>{
      _singleChannelDp(device): true,
    });
  }

  /// Kirim perintah OFF ke perangkat.
  Future<void> turnOff(Device device) async {
    if (device.isMultiChannel) {
      await turnAllOff(device);
      return;
    }
    await _sendCommand(device.id, <String, dynamic>{
      _singleChannelDp(device): false,
    });
  }

  /// Kirim perintah ke channel spesifik (multi-channel).
  Future<void> setChannelState(
    Device device,
    int channelIndex,
    bool value,
  ) async {
    _assertControllable(device);
    final List<DeviceChannel> channels = device.channels!;
    if (channelIndex < 0 || channelIndex >= channels.length) {
      throw const ApiException(
        kind: ApiExceptionKind.unsupported,
        message: 'Kanal perangkat tidak ditemukan pada data backend.',
      );
    }
    await _sendCommand(device.id, <String, dynamic>{
      channels[channelIndex].switchDp: value,
    }, channelIndex: channelIndex);
  }

  /// Kirim semua ON untuk multi-channel.
  Future<void> turnAllOn(Device device) => _sendAll(device, true);

  /// Kirim semua OFF untuk multi-channel.
  Future<void> turnAllOff(Device device) => _sendAll(device, false);

  Future<void> _sendAll(Device device, bool value) async {
    _assertControllable(device);
    final List<DeviceChannel> channels = device.channels!;
    final commands = <String, dynamic>{};
    for (final channel in channels) {
      commands[channel.switchDp] = value;
    }
    await _sendCommand(device.id, commands);
  }

  /// `switch_dp` untuk perangkat satu kanal.
  ///
  /// Tidak ada nilai cadangan seperti `switch_1`: DP yang tidak dikirim backend
  /// tidak boleh ditebak karena dapat mengirim perintah ke kanal yang salah.
  String _singleChannelDp(Device device) {
    _assertControllable(device);
    return device.channels!.first.switchDp;
  }

  /// Tolak kontrol yang belum aman sebelum menyentuh jaringan.
  ///
  /// Perangkat `verification_required`, nonaktif, atau tanpa `switch_dp` tidak
  /// boleh dikirim perintah (AI_RULES §6, §11).
  void _assertControllable(Device device) {
    if (device.isVerificationRequired) {
      throw const ApiException(
        kind: ApiExceptionKind.unsupported,
        message: 'Perangkat ini memerlukan verifikasi sebelum dikontrol.',
      );
    }
    if (!device.enabled) {
      throw const ApiException(
        kind: ApiExceptionKind.unsupported,
        message:
            'Perangkat dinonaktifkan di backend sehingga tidak dapat '
            'dikontrol.',
      );
    }
    if (!device.hasChannels) {
      throw const ApiException(
        kind: ApiExceptionKind.unsupported,
        message: 'Backend tidak mengirim DP kontrol untuk perangkat ini.',
      );
    }
  }

  /// Kirim perintah ke perangkat.
  Future<void> _sendCommand(
    String logicalId,
    Map<String, dynamic> command, {
    int? channelIndex,
  }) async {
    state = state.copyWith(
      isControlling: true,
      clearError: true,
      pendingCommand: DeviceCommand(
        deviceId: logicalId,
        dpCode: command.keys.join(','),
        value: command,
        channelIndex: channelIndex,
      ),
    );

    try {
      final repository = ref.read(deviceRepositoryProvider);
      final result = await repository.sendCommand(logicalId, command);
      state = state.copyWith(
        isControlling: false,
        clearPending: true,
        lastResult: result,
      );
    } catch (e) {
      state = state.copyWith(
        isControlling: false,
        clearPending: true,
        error: e,
      );
      rethrow;
    }
  }
}

/// Provider kontrol perangkat.
final deviceControlProvider =
    NotifierProvider<DeviceControlNotifier, DeviceControlState>(
      DeviceControlNotifier.new,
    );

/// Status monitoring untuk perangkat tertentu.
final deviceMonitoringProvider =
    Provider.family<MonitoringDeviceResult?, String>((ref, logicalId) {
      final MonitoringState monitoringState = ref.watch(monitoringProvider);
      final MonitoringResult? result =
          monitoringState.monitoring?.data?.lastResult;
      if (result == null) {
        return null;
      }
      return result.results.where((r) => r.logicalId == logicalId).firstOrNull;
    });
