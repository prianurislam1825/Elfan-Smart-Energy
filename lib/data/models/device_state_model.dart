import 'monitoring_model.dart';

/// Kondisi perangkat dari `GET /api/v1/devices/{logical_id}/state`.
///
/// Kontrak yang terverifikasi dari backend:
/// `logical_id`, `name`, `location`, `connection_status`, `last_seen_at`,
/// `last_updated_at`, `source`, `error`, dan `channels[]` yang berisi
/// `id`, `name`, `switch_dp`, `state`, `status`.
///
/// Parsing defensif: field yang hilang menjadi `null`/kosong. Nilai kanal yang
/// tidak dikirim backend tidak ditebak menjadi OFF.
class DeviceStateSnapshot {
  const DeviceStateSnapshot({
    required this.logicalId,
    required this.name,
    required this.location,
    required this.connectionStatus,
    required this.channels,
    this.lastSeenAt,
    this.lastUpdatedAt,
    this.source,
    this.error,
  });

  final String logicalId;
  final String name;
  final String location;
  final ConnectionStatus connectionStatus;
  final List<MonitoringChannelResult> channels;
  final DateTime? lastSeenAt;
  final DateTime? lastUpdatedAt;
  final String? source;
  final String? error;

  static DeviceStateSnapshot? tryParse(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return null;
    }
    final String? logicalId = _asText(map['logical_id']);
    if (logicalId == null) {
      return null;
    }

    final List<dynamic>? channelsData = map['channels'] is List
        ? map['channels'] as List<dynamic>
        : null;
    final List<MonitoringChannelResult> channels =
        channelsData
            ?.map(
              (Object? e) => MonitoringChannelResult.tryParse(
                e is Map<String, dynamic> ? e : <String, dynamic>{},
              ),
            )
            .whereType<MonitoringChannelResult>()
            .toList() ??
        <MonitoringChannelResult>[];

    return DeviceStateSnapshot(
      logicalId: logicalId,
      name: _asText(map['name']) ?? '',
      location: _asText(map['location']) ?? '',
      connectionStatus: _parseConnectionStatus(
        _asText(map['connection_status']),
      ),
      channels: channels,
      lastSeenAt: _parseDateTime(map['last_seen_at']),
      lastUpdatedAt: _parseDateTime(map['last_updated_at']),
      source: _asText(map['source']),
      error: _asText(map['error']),
    );
  }

  static ConnectionStatus _parseConnectionStatus(String? value) {
    return switch ((value ?? '').toLowerCase()) {
      'online' => ConnectionStatus.online,
      'offline' => ConnectionStatus.offline,
      _ => ConnectionStatus.unknown,
    };
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value is! String) {
      return null;
    }
    final String text = value.trim();
    if (text.isEmpty) {
      return null;
    }
    // Backend mengirim timestamp UTC (akhiran Z); tampilkan waktu lokal.
    return DateTime.tryParse(text)?.toLocal();
  }

  static String? _asText(Object? value) {
    if (value is String) {
      final String trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is num) {
      return value.toString();
    }
    if (value is bool) {
      return value ? 'true' : 'false';
    }
    return null;
  }
}
