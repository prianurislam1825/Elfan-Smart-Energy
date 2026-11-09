/// Model status monitoring dari backend ELFAN.
///
/// Berisi status agregat pemeriksaan perangkat dan hasil per perangkat.
class MonitoringStatus {
  const MonitoringStatus({
    required this.running,
    required this.intervalSeconds,
    required this.lastRunAt,
    required this.lastResult,
  });

  final bool running;
  final int intervalSeconds;
  final DateTime? lastRunAt;
  final MonitoringResult? lastResult;

  static MonitoringStatus? tryParse(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return null;
    }
    final bool? running = map['running'] is bool
        ? map['running'] as bool
        : null;
    final int? interval = map['interval_seconds'] is int
        ? map['interval_seconds'] as int
        : null;
    if (running == null || interval == null) {
      return null;
    }

    final DateTime? lastRunAt = _parseDateTimeValue(map['last_run_at']);
    final MonitoringResult? lastResult = MonitoringResult.tryParse(
      map['last_result'] is Map<String, dynamic>
          ? map['last_result'] as Map<String, dynamic>
          : <String, dynamic>{},
    );

    return MonitoringStatus(
      running: running,
      intervalSeconds: interval,
      lastRunAt: lastRunAt,
      lastResult: lastResult,
    );
  }

  static DateTime? _parseDateTimeValue(Object? value) {
    if (value is String) {
      final String text = value.trim();
      if (text.isEmpty) {
        return null;
      }
      try {
        return DateTime.parse(text);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}

/// Hasil pemeriksaan monitoring.
class MonitoringResult {
  const MonitoringResult({
    required this.checkedAt,
    required this.totalDevices,
    required this.monitoredDevices,
    required this.online,
    required this.offline,
    required this.unknown,
    required this.unsupportedDevices,
    required this.results,
  });

  final DateTime? checkedAt;
  final int totalDevices;
  final int monitoredDevices;
  final int online;
  final int offline;
  final int unknown;
  final int unsupportedDevices;
  final List<MonitoringDeviceResult> results;

  static MonitoringResult? tryParse(Map<String, dynamic> map) {
    if (map.isEmpty) return null;
    final DateTime? checkedAt = _parseDateTimeValue(map['checked_at']);
    final int? total = _asInt(map['total_devices']);
    final int? monitored = _asInt(map['monitored_devices']);
    final int? online = _asInt(map['online']);
    final int? offline = _asInt(map['offline']);
    final int? unknown = _asInt(map['unknown']);
    final int? unsupported = _asInt(map['unsupported_devices']);

    if (total == null ||
        monitored == null ||
        online == null ||
        offline == null ||
        unknown == null ||
        unsupported == null) {
      return null;
    }

    final List<dynamic>? resultsData = map['results'] is List
        ? map['results'] as List<dynamic>
        : null;
    final List<MonitoringDeviceResult> results =
        resultsData
            ?.map((e) {
              return MonitoringDeviceResult.tryParse(
                e is Map<String, dynamic> ? e : <String, dynamic>{},
              );
            })
            .whereType<MonitoringDeviceResult>()
            .toList() ??
        <MonitoringDeviceResult>[];

    return MonitoringResult(
      checkedAt: checkedAt,
      totalDevices: total,
      monitoredDevices: monitored,
      online: online,
      offline: offline,
      unknown: unknown,
      unsupportedDevices: unsupported,
      results: results,
    );
  }

  static DateTime? _parseDateTimeValue(Object? value) {
    if (value is String) {
      final String text = value.trim();
      if (text.isEmpty) {
        return null;
      }
      try {
        return DateTime.parse(text);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static int? _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  int get supportedDevices => totalDevices - unsupportedDevices;
}

/// Hasil monitoring per perangkat.
class MonitoringDeviceResult {
  const MonitoringDeviceResult({
    required this.logicalId,
    required this.name,
    required this.type,
    required this.connectionStatus,
    required this.success,
    required this.channels,
  });

  final String logicalId;
  final String name;
  final String type;
  final ConnectionStatus connectionStatus;
  final bool success;
  final List<MonitoringChannelResult> channels;

  static MonitoringDeviceResult? tryParse(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return null;
    }
    final String? logicalId = _asText(map['logical_id']);
    final String? name = _asText(map['name']);
    final String? type = _asText(map['type']);
    final String? connStatus = _asText(map['connection_status']);
    final bool? success = map['success'] is bool
        ? map['success'] as bool
        : null;

    if (logicalId == null ||
        name == null ||
        type == null ||
        connStatus == null ||
        success == null) {
      return null;
    }

    final ConnectionStatus status = _parseConnectionStatus(connStatus);
    final List<dynamic>? channelsData = map['channels'] is List
        ? map['channels'] as List<dynamic>
        : null;
    final List<MonitoringChannelResult> channels =
        channelsData
            ?.map((e) {
              return MonitoringChannelResult.tryParse(
                e is Map<String, dynamic> ? e : <String, dynamic>{},
              );
            })
            .whereType<MonitoringChannelResult>()
            .toList() ??
        <MonitoringChannelResult>[];

    return MonitoringDeviceResult(
      logicalId: logicalId,
      name: name,
      type: type,
      connectionStatus: status,
      success: success,
      channels: channels,
    );
  }

  static ConnectionStatus _parseConnectionStatus(String? value) {
    final lower = (value ?? '').toLowerCase();
    if (lower == 'online') {
      return ConnectionStatus.online;
    }
    if (lower == 'offline') {
      return ConnectionStatus.offline;
    }
    return ConnectionStatus.unknown;
  }

  static String? _asText(Object? value) {
    if (value is String) {
      final trimmed = value.trim();
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
}

/// Status koneksi perangkat.
enum ConnectionStatus { online, offline, unknown }

extension ConnectionStatusExtension on ConnectionStatus {
  String get displayName {
    return switch (this) {
      ConnectionStatus.online => 'Online',
      ConnectionStatus.offline => 'Offline',
      ConnectionStatus.unknown => 'Unknown',
    };
  }

  bool get isOnline => this == ConnectionStatus.online;
  bool get isOffline => this == ConnectionStatus.offline;
  bool get isUnknown => this == ConnectionStatus.unknown;
}

/// Hasil monitoring per channel.
class MonitoringChannelResult {
  const MonitoringChannelResult({
    required this.id,
    required this.name,
    required this.switchDp,
    required this.state,
    required this.status,
  });

  final String id;
  final String name;
  final String switchDp;
  final ChannelState state;
  final ChannelStatus status;

  static MonitoringChannelResult? tryParse(Map<String, dynamic> map) {
    if (map.isEmpty) return null;
    final String? id = _asText(map['id']);
    final String? name = _asText(map['name']);
    final String? switchDp = _asText(map['switch_dp']);
    final String? stateStr = _asText(map['state']);
    final String? statusStr = _asText(map['status']);

    if (id == null ||
        name == null ||
        switchDp == null ||
        stateStr == null ||
        statusStr == null) {
      return null;
    }

    return MonitoringChannelResult(
      id: id,
      name: name,
      switchDp: switchDp,
      state: _parseChannelState(stateStr),
      status: _parseChannelStatus(statusStr),
    );
  }

  static ChannelState _parseChannelState(String? value) {
    final lower = (value ?? '').toLowerCase();
    if (lower == 'on') {
      return ChannelState.on;
    }
    if (lower == 'off') {
      return ChannelState.off;
    }
    return ChannelState.unknown;
  }

  static ChannelStatus _parseChannelStatus(String? value) {
    final lower = (value ?? '').toLowerCase();
    if (lower == 'online') {
      return ChannelStatus.online;
    }
    if (lower == 'offline') {
      return ChannelStatus.offline;
    }
    if (lower == 'success') {
      return ChannelStatus.success;
    }
    if (lower == 'fail') {
      return ChannelStatus.fail;
    }
    return ChannelStatus.unknown;
  }

  static String? _asText(Object? value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is bool) return value ? 'true' : 'false';
    if (value is num) return value.toString();
    return null;
  }
}

/// State kanal (ON/OFF).
enum ChannelState { on, off, unknown }

extension ChannelStateExtension on ChannelState {
  String get displayName {
    return switch (this) {
      ChannelState.on => 'ON',
      ChannelState.off => 'OFF',
      ChannelState.unknown => '--',
    };
  }

  bool get isOn => this == ChannelState.on;
  bool get isOff => this == ChannelState.off;
}

/// Status channel pemeriksaan.
enum ChannelStatus { online, offline, success, fail, unknown }

extension ChannelStatusExtension on ChannelStatus {
  String get displayName {
    return switch (this) {
      ChannelStatus.online => 'Online',
      ChannelStatus.offline => 'Offline',
      ChannelStatus.success => 'Success',
      ChannelStatus.fail => 'Fail',
      ChannelStatus.unknown => 'Unknown',
    };
  }
}

/// Respons status monitoring dari backend.
class MonitoringStatusResponse {
  const MonitoringStatusResponse({required this.success, required this.data});

  final bool success;
  final MonitoringStatus? data;

  static MonitoringStatusResponse? tryParse(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return null;
    }
    final bool? success = map['success'] is bool
        ? map['success'] as bool
        : null;
    if (success == null) {
      return null;
    }
    final MonitoringStatus? data = MonitoringStatus.tryParse(
      map['data'] is Map<String, dynamic>
          ? map['data'] as Map<String, dynamic>
          : <String, dynamic>{},
    );
    return MonitoringStatusResponse(success: success, data: data);
  }
}
