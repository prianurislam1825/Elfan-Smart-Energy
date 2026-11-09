import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/config/app_config_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/component_theme.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/backend_health_model.dart';
import '../../../data/models/device_model.dart';
import '../../../data/models/monitoring_model.dart';
import '../../../data/providers/backend_health_provider.dart';
import '../../../data/providers/device_providers.dart';
import '../../../data/services/api_exception.dart';
import '../../../shared/widgets/elfan_brand.dart';
import '../../../shared/widgets/info_chip.dart';

/// Halaman awal ELFAN.
///
/// Ringkasan memakai data aktual: status koneksi backend (`GET /health`),
/// daftar perangkat (`GET /api/v1/devices`), dan status monitoring
/// (`GET /api/v1/monitoring/status`). Tidak ada angka statistik yang dibuat
/// sendiri: jika backend belum memberi hasil, UI menampilkan keterangan.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppConfig config = ref.watch(appConfigProvider);
    final BackendConnectionState backend = ref.watch(backendHealthProvider);
    final DeviceListState deviceList = ref.watch(deviceListProvider);
    final MonitoringState monitoring = ref.watch(monitoringProvider);

    Future<void> refreshAll() async {
      await Future.wait(<Future<void>>[
        ref.read(backendHealthProvider.notifier).check(),
        ref.read(deviceListProvider.notifier).refresh(),
        ref.read(monitoringProvider.notifier).refresh(),
      ]);
    }

    final double padding = Responsive.pagePadding(context);

    return Scaffold(
      appBar: ElfanAppBar(
        title: 'Home',
        subtitle: 'Ringkasan fasilitas',
        actions: <Widget>[
          IconButton(
            onPressed: refreshAll,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Muat Ulang',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ResponsiveContent(
          child: RefreshIndicator(
            onRefresh: refreshAll,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(padding, 20, padding, 28),
              children: <Widget>[
                const _WelcomeCard(),
                const SizedBox(height: 16),
                _BackendStatusCard(
                  config: config,
                  state: backend,
                  onCheck: () =>
                      ref.read(backendHealthProvider.notifier).check(),
                ),
                const SizedBox(height: 16),
                _DeviceSummaryCard(
                  deviceList: deviceList,
                  monitoring: monitoring,
                  onRefresh: () async {
                    await Future.wait(<Future<void>>[
                      ref.read(deviceListProvider.notifier).refresh(),
                      ref.read(monitoringProvider.notifier).refresh(),
                    ]);
                  },
                ),
                const SizedBox(height: 16),
                _LocationSummaryCard(deviceList: deviceList),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[ColorTokens.primary, ColorTokens.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ComponentTheme.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const ElfanWordmark(color: Colors.white),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  AppConstants.foundationPhaseLabel,
                  style: textTheme.labelSmall?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            AppConstants.tagline,
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppConstants.description,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }
}

/// Status koneksi backend berdasarkan pemeriksaan `GET /health`.
class _BackendStatusCard extends StatelessWidget {
  const _BackendStatusCard({
    required this.config,
    required this.state,
    required this.onCheck,
  });

  final AppConfig config;
  final BackendConnectionState state;
  final Future<void> Function() onCheck;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? problem = config.apiBaseUrlValidationError;
    final BackendHealth? health = state.health;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.dns_outlined,
                  size: 20,
                  color: ColorTokens.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Status backend', style: textTheme.titleMedium),
                ),
                InfoChip(
                  label: state.status.displayName,
                  icon: _iconFor(state.status),
                  tone: _toneFor(state.status),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Host API', style: textTheme.labelSmall),
            const SizedBox(height: 2),
            Text(
              config.apiHost ?? 'Belum ditentukan',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            if (problem != null) ...<Widget>[
              Text(problem, style: textTheme.bodySmall),
              const SizedBox(height: 6),
              Text(
                'Tetapkan saat menjalankan aplikasi, misalnya '
                '--dart-define=${AppConfig.apiBaseUrlDefine}=https://host-api',
                style: textTheme.bodySmall,
              ),
            ] else ...<Widget>[
              Text(_description(health), style: textTheme.bodySmall),
              if (state.lastCheckedAt != null) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  'Diperiksa: ${formatClock(state.lastCheckedAt!)}',
                  style: textTheme.labelSmall,
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: state.isChecking ? null : onCheck,
                  icon: state.isChecking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_tethering_rounded, size: 18),
                  label: Text(
                    state.isChecking ? 'Memeriksa...' : 'Periksa Koneksi',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _description(BackendHealth? health) {
    switch (state.status) {
      case BackendConnectionStatus.unknown:
        return 'Belum ada pemeriksaan koneksi ke backend.';
      case BackendConnectionStatus.checking:
        return 'Memeriksa endpoint health backend...';
      case BackendConnectionStatus.connected:
        final List<String> parts = <String>[
          'Endpoint health merespons dalam ${health?.latencyMs ?? 0} ms.',
        ];
        if (health?.status != null) {
          parts.add('Status backend: ${health!.status}.');
        }
        if (health?.application != null) {
          parts.add('Aplikasi: ${health!.application}.');
        }
        if (health?.environment != null) {
          parts.add('Lingkungan: ${health!.environment}.');
        }
        return parts.join(' ');
      case BackendConnectionStatus.unreachable:
        return _errorMessage(state.error);
    }
  }

  String _errorMessage(Object? error) {
    if (error is ApiException) {
      return error.userMessage;
    }
    if (error is String) {
      return error;
    }
    return 'Tidak dapat memeriksa koneksi backend.';
  }

  IconData _iconFor(BackendConnectionStatus status) {
    return switch (status) {
      BackendConnectionStatus.unknown => Icons.help_outline_rounded,
      BackendConnectionStatus.checking => Icons.sync_rounded,
      BackendConnectionStatus.connected => Icons.check_circle_outline_rounded,
      BackendConnectionStatus.unreachable => Icons.error_outline_rounded,
    };
  }

  ChipTone _toneFor(BackendConnectionStatus status) {
    return switch (status) {
      BackendConnectionStatus.unknown => ChipTone.neutral,
      BackendConnectionStatus.checking => ChipTone.primary,
      BackendConnectionStatus.connected => ChipTone.success,
      BackendConnectionStatus.unreachable => ChipTone.danger,
    };
  }
}

/// Ringkasan perangkat dan monitoring dari backend.
class _DeviceSummaryCard extends StatelessWidget {
  const _DeviceSummaryCard({
    required this.deviceList,
    required this.monitoring,
    required this.onRefresh,
  });

  final DeviceListState deviceList;
  final MonitoringState monitoring;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final MonitoringStatus? status = monitoring.monitoring?.data;
    final MonitoringResult? result = status?.lastResult;
    final DateTime? lastUpdated = _latestUpdate();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.devices_other,
                  size: 20,
                  color: ColorTokens.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ringkasan perangkat',
                    style: textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: deviceList.isLoading ? null : onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Muat Ulang',
                ),
              ],
            ),
            if (deviceList.isLoading && deviceList.total == 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (deviceList.error != null &&
                deviceList.devices.isEmpty) ...<Widget>[
              Text(_errorMessage(deviceList.error), style: textTheme.bodySmall),
            ] else ...<Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: _StatTile(
                      label: 'Total perangkat',
                      value: deviceList.total.toString(),
                      color: ColorTokens.primary,
                    ),
                  ),
                  Expanded(
                    child: _StatTile(
                      label: 'Didukung',
                      value: deviceList.supportedDevices.toString(),
                      color: ColorTokens.success,
                    ),
                  ),
                  Expanded(
                    child: _StatTile(
                      label: 'Perlu verifikasi',
                      value: deviceList.unsupportedCount.toString(),
                      color: ColorTokens.warning,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text('Status monitoring', style: textTheme.titleSmall),
              const SizedBox(height: 8),
              if (status == null) ...<Widget>[
                Text(
                  'Belum ada data monitoring dari backend.',
                  style: textTheme.bodySmall,
                ),
              ] else ...<Widget>[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    InfoChip(
                      label: status.running
                          ? 'Monitoring berjalan'
                          : 'Monitoring tidak aktif',
                      icon: status.running
                          ? Icons.play_circle_outline_rounded
                          : Icons.pause_circle_outline_rounded,
                      tone: status.running
                          ? ChipTone.success
                          : ChipTone.warning,
                    ),
                    InfoChip(
                      label:
                          'Interval ${_formatInterval(status.intervalSeconds)}',
                      icon: Icons.timer_outlined,
                      tone: ChipTone.primary,
                    ),
                    if (status.lastRunAt != null)
                      InfoChip(
                        label: 'Terakhir ${formatClock(status.lastRunAt!)}',
                        icon: Icons.access_time,
                        tone: ChipTone.neutral,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (result == null)
                  Text(
                    'Belum ada hasil pemeriksaan monitoring.',
                    style: textTheme.bodySmall,
                  )
                else ...<Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _StatTile(
                          label: 'Online',
                          value: result.online.toString(),
                          color: ColorTokens.success,
                        ),
                      ),
                      Expanded(
                        child: _StatTile(
                          label: 'Offline',
                          value: result.offline.toString(),
                          color: ColorTokens.danger,
                        ),
                      ),
                      Expanded(
                        child: _StatTile(
                          label: 'Unknown',
                          value: result.unknown.toString(),
                          color: ColorTokens.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Terpantau ${result.monitoredDevices} dari '
                    '${result.totalDevices} perangkat'
                    '${result.checkedAt == null ? '' : ' · diperiksa ${formatClock(result.checkedAt!)}'}',
                    style: textTheme.bodySmall,
                  ),
                ],
              ],
            ],
            if (lastUpdated != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                'Data diperbarui ${formatClock(lastUpdated)}',
                style: textTheme.labelSmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  DateTime? _latestUpdate() {
    final DateTime? devices = deviceList.lastRefreshed;
    final DateTime? monitor = monitoring.lastRefreshed;
    if (devices == null) return monitor;
    if (monitor == null) return devices;
    return devices.isAfter(monitor) ? devices : monitor;
  }

  String _errorMessage(Object? error) {
    if (error is ApiException) {
      return error.userMessage;
    }
    if (error is String) {
      return error;
    }
    return 'Gagal memuat data perangkat.';
  }
}

/// Ringkasan jumlah perangkat per lokasi.
class _LocationSummaryCard extends StatelessWidget {
  const _LocationSummaryCard({required this.deviceList});

  final DeviceListState deviceList;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Map<String, int> counts = <String, int>{};
    for (final Device device in deviceList.devices) {
      final String location = device.location.isEmpty
          ? 'Tanpa lokasi'
          : device.location;
      counts[location] = (counts[location] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: ColorTokens.primary,
                ),
                const SizedBox(width: 8),
                Text('Ringkasan lokasi', style: textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            if (deviceList.isLoading && deviceList.devices.isEmpty)
              Text('Memuat lokasi perangkat...', style: textTheme.bodySmall)
            else if (counts.isEmpty)
              Text(
                'Belum ada data lokasi perangkat dari backend.',
                style: textTheme.bodySmall,
              )
            else
              for (final MapEntry<String, int> entry in counts.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          entry.key,
                          style: textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InfoChip(
                        label: '${entry.value} perangkat',
                        icon: Icons.devices_other_outlined,
                        tone: ChipTone.primary,
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: textTheme.labelSmall),
      ],
    );
  }
}

String _formatInterval(int seconds) {
  if (seconds <= 0) {
    return 'tidak diketahui';
  }
  if (seconds < 60) {
    return '$seconds detik';
  }
  final int minutes = seconds ~/ 60;
  final int rest = seconds % 60;
  return rest == 0 ? '$minutes menit' : '$minutes menit $rest detik';
}
