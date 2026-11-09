/// Model perangkat dari backend ELFAN.
///
/// Parsing defensive terhadap field null, hilang, atau tipe tidak sesuai.
/// Field tambahan dipertahankan dalam [extraFields] agar informasi tidak hilang.
class Device {
  const Device({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    required this.deviceId,
    required this.category,
    required this.enabled,
    this.channels,
    this.monitoringDps,
    this.functions,
    this.commands,
    this.profiles,
    this.parentDeviceId,
    this.onDeviceId,
    this.offDeviceId,
    this.onSequence,
    this.offCommand,
    this.statusMode,
    this.note,
    this.verificationRequired,
    this.extraFields = const <String, dynamic>{},
  });

  final String id;
  final String name;
  final String location;
  final String type;
  final String deviceId;
  final String category;
  final bool enabled;
  final List<DeviceChannel>? channels;
  final List<dynamic>? monitoringDps;
  final List<dynamic>? functions;
  final List<dynamic>? commands;
  final List<dynamic>? profiles;
  final String? parentDeviceId;
  final String? onDeviceId;
  final String? offDeviceId;
  final String? onSequence;
  final String? offCommand;
  final String? statusMode;
  final String? note;
  final bool? verificationRequired;
  final Map<String, dynamic> extraFields;

  bool get hasChannels => channels != null && channels!.isNotEmpty;
  bool get isMultiChannel => hasChannels && channels!.length > 1;
  bool get isVerificationRequired => verificationRequired == true;
  bool get isSupported => !isVerificationRequired;

  /// Representasi aman untuk logging/diagnostik tanpa menampilkan device_id.
  String get safeDisplayId =>
      'DEV-${id.substring(0, id.length > 8 ? 8 : id.length)}';

  static Device? tryParse(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return null;
    }

    final String? id = _asText(map['id']) ?? _asText(map['logical_id']);
    final String? name = _asText(map['name']);
    final String? location = _asText(map['location']);
    final String? type = _asText(map['type']);
    final String? deviceId = _asText(map['device_id']);
    final String? category = _asText(map['category']);

    if (id == null || name == null) {
      return null;
    }

    return Device(
      id: id,
      name: name,
      location: location ?? '',
      type: type ?? '',
      deviceId: deviceId ?? '',
      category: category ?? '',
      enabled: _asBool(map['enabled']),
      channels: _parseChannels(map['channels']),
      monitoringDps: _asList(map['monitoring_dps']),
      functions: _asList(map['functions']),
      commands: _asList(map['commands']),
      profiles: _asList(map['profiles']),
      parentDeviceId: _asText(map['parent_device_id']),
      onDeviceId: _asText(map['on_device_id']),
      offDeviceId: _asText(map['off_device_id']),
      onSequence: _asText(map['on_sequence']),
      offCommand: _asText(map['off_command']),
      statusMode: _asText(map['status_mode']),
      note: _asText(map['note']),
      verificationRequired: _asBool(map['verification_required']),
      extraFields: _extractExtraFields(map),
    );
  }

  static List<DeviceChannel>? _parseChannels(Object? data) {
    if (data == null) {
      return null;
    }
    if (data is List) {
      return data
          .map(
            (e) => DeviceChannel.tryParse(
              e is Map<String, dynamic> ? e : <String, dynamic>{},
            ),
          )
          .whereType<DeviceChannel>()
          .toList();
    }
    if (data is Map) {
      return data.entries
          .map(
            (e) => DeviceChannel.tryParse(
              e.value is Map<String, dynamic> ? e.value : <String, dynamic>{},
            ),
          )
          .whereType<DeviceChannel>()
          .toList();
    }
    return null;
  }

  static List<dynamic>? _asList(Object? value) =>
      value is List ? value : null;
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

  static bool _asBool(Object? value) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'on';
    }
    if (value is num) {
      return value != 0;
    }
    return false;
  }

  static Map<String, dynamic> _extractExtraFields(Map<String, dynamic> map) {
    final knownKeys = <String>{
      'id',
      'logical_id',
      'name',
      'location',
      'type',
      'device_id',
      'category',
      'enabled',
      'channels',
      'monitoring_dps',
      'functions',
      'commands',
      'profiles',
      'parent_device_id',
      'on_device_id',
      'off_device_id',
      'on_sequence',
      'off_command',
      'status_mode',
      'note',
      'verification_required',
    };
    return map.entries
        .where((entry) => !knownKeys.contains(entry.key))
        .fold<Map<String, dynamic>>({}, (acc, entry) {
          acc[entry.key] = entry.value;
          return acc;
        });
  }

  Device copyWith({
    String? id,
    String? name,
    String? location,
    String? type,
    String? deviceId,
    String? category,
    bool? enabled,
    List<DeviceChannel>? channels,
    List<dynamic>? monitoringDps,
    List<dynamic>? functions,
    List<dynamic>? commands,
    List<dynamic>? profiles,
    String? parentDeviceId,
    String? onDeviceId,
    String? offDeviceId,
    String? onSequence,
    String? offCommand,
    String? statusMode,
    String? note,
    bool? verificationRequired,
    Map<String, dynamic>? extraFields,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      type: type ?? this.type,
      deviceId: deviceId ?? this.deviceId,
      category: category ?? this.category,
      enabled: enabled ?? this.enabled,
      channels: channels ?? this.channels,
      monitoringDps: monitoringDps ?? this.monitoringDps,
      functions: functions ?? this.functions,
      commands: commands ?? this.commands,
      profiles: profiles ?? this.profiles,
      parentDeviceId: parentDeviceId ?? this.parentDeviceId,
      onDeviceId: onDeviceId ?? this.onDeviceId,
      offDeviceId: offDeviceId ?? this.offDeviceId,
      onSequence: onSequence ?? this.onSequence,
      offCommand: offCommand ?? this.offCommand,
      statusMode: statusMode ?? this.statusMode,
      note: note ?? this.note,
      verificationRequired: verificationRequired ?? this.verificationRequired,
      extraFields: extraFields ?? this.extraFields,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'type': type,
      'device_id': deviceId,
      'category': category,
      'enabled': enabled,
      if (channels != null)
        'channels': channels!.map((c) => c.toJson()).toList(),
      if (monitoringDps != null) 'monitoring_dps': monitoringDps,
      if (functions != null) 'functions': functions,
      if (commands != null) 'commands': commands,
      if (profiles != null) 'profiles': profiles,
      if (parentDeviceId != null) 'parent_device_id': parentDeviceId,
      if (onDeviceId != null) 'on_device_id': onDeviceId,
      if (offDeviceId != null) 'off_device_id': offDeviceId,
      if (onSequence != null) 'on_sequence': onSequence,
      if (offCommand != null) 'off_command': offCommand,
      if (statusMode != null) 'status_mode': statusMode,
      if (note != null) 'note': note,
      if (verificationRequired != null)
        'verification_required': verificationRequired,
      ...extraFields,
    };
  }

  @override
  String toString() {
    return 'Device(id: $id, name: $name, location: $location, type: $type, category: $category, enabled: $enabled, channels: ${channels?.length ?? 0})';
  }
}

/// Channel untuk perangkat multi-channel.
class DeviceChannel {
  const DeviceChannel({
    required this.id,
    required this.name,
    required this.switchDp,
    this.state,
    this.status,
  });

  final String id;
  final String name;
  final String switchDp;
  final String? state;
  final String? status;

  bool get isOn => state?.toLowerCase() == 'on';
  bool get isOff => state?.toLowerCase() == 'off';

  static DeviceChannel? tryParse(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return null;
    }
    final String? id = _asText(map['id']);
    final String? name = _asText(map['name']);
    final String? switchDp = _asText(map['switch_dp']);
    if (id == null || name == null || switchDp == null) {
      return null;
    }
    return DeviceChannel(
      id: id,
      name: name,
      switchDp: switchDp,
      state: _asText(map['state']),
      status: _asText(map['status']),
    );
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'switch_dp': switchDp,
      if (state != null) 'state': state,
      if (status != null) 'status': status,
    };
  }

  @override
  String toString() =>
      'DeviceChannel(id: $id, name: $name, switchDp: $switchDp, state: $state)';
}

/// Respons daftar perangkat dari backend.
class DeviceListResponse {
  const DeviceListResponse({required this.total, required this.devices});

  final int total;
  final List<Device> devices;

  static DeviceListResponse? tryParse(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return null;
    }
    final int? total = map['total'] is int ? map['total'] as int : null;
    if (total == null) {
      return null;
    }
    final List<dynamic>? devicesData = map['devices'] is List
        ? map['devices'] as List<dynamic>
        : null;
    if (devicesData == null) {
      return null;
    }
    final List<Device> devices = devicesData
        .map(
          (e) => Device.tryParse(
            e is Map<String, dynamic> ? e : <String, dynamic>{},
          ),
        )
        .whereType<Device>()
        .toList();
    return DeviceListResponse(total: total, devices: devices);
  }
}
