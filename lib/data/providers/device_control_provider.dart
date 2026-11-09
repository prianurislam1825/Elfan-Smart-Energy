import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show immutable;

import 'device_providers.dart';
import '../models/device_model.dart';
import '../models/monitoring_model.dart';

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
    await _sendCommand(device.id, _singleChannelCommand(device, true));
  }

  /// Kirim perintah OFF ke perangkat.
  Future<void> turnOff(Device device) async {
    if (device.isMultiChannel) {
      await turnAllOff(device);
      return;
    }
    await _sendCommand(device.id, _singleChannelCommand(device, false));
  }

  /// Kirim perintah ke channel spesifik (multi-channel).
  Future<void> setChannelState(
    Device device,
    int channelIndex,
    bool value,
  ) async {
    final channel = device.channels?.elementAtOrNull(channelIndex);
    if (channel == null) {
      state = state.copyWith(error: 'Kanal tidak ditemukan');
      return;
    }
    await _sendCommand(device.id, <String, dynamic>{
      channel.switchDp: value,
    }, channelIndex: channelIndex);
  }

  /// Kirim semua ON untuk multi-channel.
  Future<void> turnAllOn(Device device) async {
    if (!device.isMultiChannel) {
      await _sendCommand(device.id, _singleChannelCommand(device, true));
      return;
    }

    final commands = <String, dynamic>{};
    for (final channel in device.channels!) {
      commands[channel.switchDp] = true;
    }
    await _sendCommand(device.id, commands);
  }

  /// Kirim semua OFF untuk multi-channel.
  Future<void> turnAllOff(Device device) async {
    if (!device.isMultiChannel) {
      await _sendCommand(device.id, _singleChannelCommand(device, false));
      return;
    }

    final commands = <String, dynamic>{};
    for (final channel in device.channels!) {
      commands[channel.switchDp] = false;
    }
    await _sendCommand(device.id, commands);
  }

  /// Kirim perintah custom.
  Future<void> sendCustomCommand(
    String logicalId,
    Map<String, dynamic> command, {
    int? channelIndex,
  }) async {
    await _sendCommand(logicalId, command, channelIndex: channelIndex);
  }

  /// Gunakan `switch_dp` dari channel jika backend menyediakannya.
  Map<String, dynamic> _singleChannelCommand(Device device, bool value) {
    final List<DeviceChannel>? channels = device.channels;
    final String dp = channels != null && channels.isNotEmpty
        ? channels.first.switchDp
        : 'switch_1';
    return <String, dynamic>{dp: value};
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
