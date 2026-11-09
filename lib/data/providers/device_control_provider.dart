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
    bool clearLastError = false,
    bool clearPending = false,
  }) {
    return DeviceControlState(
      isControlling: isControlling ?? this.isControlling,
      pendingCommand: clearPending ? null : (pendingCommand ?? this.pendingCommand),
      lastResult: clearLastError ? null : (lastResult ?? this.lastResult),
      error: error ?? this.error,
    );
  }
}

/// Notifier untuk kontrol perangkat.
class DeviceControlNotifier extends Notifier<DeviceControlState> {
  DeviceControlNotifier();

  @override
  DeviceControlState build() {
    return const DeviceControlState();
  }

  /// Kirim perintah ON ke perangkat.
  Future<void> turnOn(Device device) async {
    if (device.isMultiChannel) {
      await _sendCommand(device.id, {'switch_all': true});
    } else {
      await _sendCommand(device.id, {'switch_1': true});
    }
  }

  /// Kirim perintah OFF ke perangkat.
  Future<void> turnOff(Device device) async {
    if (device.isMultiChannel) {
      await _sendCommand(device.id, {'switch_all': false});
    } else {
      await _sendCommand(device.id, {'switch_1': false});
    }
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
    final cmd = <String, dynamic>{channel.switchDp: value};
    await _sendCommand(device.id, cmd);
  }

  /// Kirim semua ON untuk multi-channel.
  Future<void> turnAllOn(Device device) async {
    if (!device.isMultiChannel) {
      await _sendCommand(device.id, {'switch_1': true});
      return;
    }

    final commands = <String, dynamic>{};
    if (device.channels != null) {
      for (var i = 0; i < device.channels!.length; i++) {
        final channel = device.channels![i];
        commands[channel.switchDp] = true;
      }
    }
    await _sendCommand(device.id, commands);
  }

  /// Kirim semua OFF untuk multi-channel.
  Future<void> turnAllOff(Device device) async {
    if (!device.isMultiChannel) {
      await _sendCommand(device.id, {'switch_1': false});
      return;
    }

    final commands = <String, dynamic>{};
    if (device.channels != null) {
      for (var i = 0; i < device.channels!.length; i++) {
        final channel = device.channels![i];
        commands[channel.switchDp] = false;
      }
    }
    await _sendCommand(device.id, commands);
  }

  /// Kirim perintah ke perangkat.
  Future<void> _sendCommand(
    String logicalId,
    Map<String, dynamic> command,
  ) async {
    state = state.copyWith(
      isControlling: true,
      clearLastError: true,
    );

    try {
      final repository = ref.read(deviceRepositoryProvider);
      final result = await repository.sendCommand(
        logicalId,
        command,
      );
      state = state.copyWith(
        isControlling: false,
        lastResult: result,
      );
    } catch (e) {
      state = state.copyWith(
        isControlling: false,
        error: e,
      );
      rethrow;
    }
  }

  /// Kirim perintah custom.
  Future<void> sendCustomCommand(
    String logicalId,
    Map<String, dynamic> command,
  ) async {
    state = state.copyWith(
      isControlling: true,
      clearLastError: true,
    );

    try {
      final repository = ref.read(deviceRepositoryProvider);
      final result = await repository.sendCommand(logicalId, command);
      state = state.copyWith(
        isControlling: false,
        lastResult: result,
      );
    } catch (e) {
      state = state.copyWith(
        isControlling: false,
        error: e,
      );
      rethrow;
    }
  }

  /// Kirim perintah countdown.
  Future<void> setCountdown(
    Device device,
    int seconds,
  ) async {
    await _sendCommand(device.id, {'countdown_1': seconds});
  }
}

/// Provider kontrol perangkat.
final deviceControlProvider = NotifierProvider<DeviceControlNotifier, DeviceControlState>(
  DeviceControlNotifier.new,
);

/// Status monitoring untuk perangkat tertentu.
final deviceMonitoringProvider = Provider.family<MonitoringDeviceResult?, String>(
  (ref, logicalId) {
    final monitoringState = ref.watch(monitoringProvider);
    final monitoring = monitoringState.monitoring;
    if (monitoring == null ||
        monitoring.data == null ||
        monitoring.data!.lastResult == null) {
      return null;
    }
    final results = monitoring.data!.lastResult!.results;
    return results.where((r) => r.logicalId == logicalId).firstOrNull;
  },
);
