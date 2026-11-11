import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/config/app_config_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/component_theme.dart';
import '../../../core/utils/date_format.dart';
import '../../../shared/utils/error_message.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/backend_health_model.dart';
import '../../../data/models/monitoring_model.dart';
import '../../../data/providers/backend_health_provider.dart';
import '../../../data/providers/device_providers.dart';
import '../../../shared/widgets/elfan_brand.dart';
import '../../../shared/widgets/info_chip.dart';
import '../../../shared/widgets/info_row.dart';
import '../../../shared/widgets/section_card.dart';

/// Halaman Pengaturan.
///
/// Hanya menampilkan konfigurasi dan status yang benar-benar diketahui
/// aplikasi: host API dari `--dart-define`, hasil `GET /health`, status
/// `GET /api/v1/monitoring/status`, serta identitas aplikasi. Tidak ada
/// logout, manajemen akun, atau preferensi yang endpoint-nya belum tersedia.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppConfig config = ref.watch(appConfigProvider);
    final BackendConnectionState backend = ref.watch(backendHealthProvider);
    final MonitoringState monitoring = ref.watch(monitoringProvider);
    final DeviceListState devices = ref.watch(deviceListProvider);
    final double padding = Responsive.pagePadding(context);

    return Scaffold(
      appBar: const ElfanAppBar(
        title: 'Pengaturan',
        subtitle: 'Konfigurasi & status sistem',
        showBrand: false,
      ),
      body: SafeArea(
        top: false,
        child: ResponsiveContent(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.wait(<Future<void>>[
                ref.read(backendHealthProvider.notifier).check(),
                ref.read(monitoringProvider.notifier).refresh(),
                ref.read(deviceListProvider.notifier).refresh(),
              ]);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(padding, 20, padding, 28),
              children: <Widget>[
                _ConnectionSection(config: config, backend: backend),
                const SizedBox(height: ComponentTheme.space16),
                _MonitoringSection(
                  monitoring: monitoring,
                  totalDevices: devices.total,
                  onCheck: () => ref.read(monitoringProvider.notifier).check(),
                  onOpenDevices: () => context.go(AppRoutes.devices),
                ),
                const SizedBox(height: ComponentTheme.space16),
                const _ApiConfigSection(),
                const SizedBox(height: ComponentTheme.space16),
                const _AppInfoSection(),
                const SizedBox(height: ComponentTheme.space16),
                const _UnavailableSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConnectionSection extends ConsumerWidget {
  const _ConnectionSection({required this.config, required this.backend});

  final AppConfig config;
  final BackendConnectionState backend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BackendHealth? health = backend.health;
    final String? problem = config.apiBaseUrlValidationError;

    return SectionCard(
      title: 'Koneksi backend',
      icon: Icons.dns_outlined,
      trailing: InfoChip(
        label: backend.status.displayName,
        icon: _connectionIcon(backend.status),
        tone: _connectionTone(backend.status),
      ),
      children: <Widget>[
        InfoRow(label: 'Host API', value: config.apiHost ?? 'Belum ditentukan'),
        InfoRow(
          label: 'Endpoint health',
          value: problem == null ? 'Dapat digunakan' : 'Belum valid',
          valueColor: problem == null
              ? ColorTokens.success
              : ColorTokens.danger,
        ),
        if (health != null) ...<Widget>[
          InfoRow(label: 'Latensi', value: '${health.latencyMs} ms'),
          if (health.status != null)
            InfoRow(label: 'Status backend', value: health.status!),
          if (health.application != null)
            InfoRow(label: 'Aplikasi', value: health.application!),
          if (health.environment != null)
            InfoRow(label: 'Lingkungan', value: health.environment!),
        ],
        if (backend.lastCheckedAt != null)
          InfoRow(
            label: 'Diperiksa',
            value: formatDateTime(backend.lastCheckedAt!),
          ),
        if (backend.error != null)
          InfoRow(
            label: 'Kegagalan',
            value: describeApiError(backend.error),
            valueColor: ColorTokens.warning,
          ),
        const SizedBox(height: ComponentTheme.space4),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: backend.isChecking
                ? null
                : () => ref.read(backendHealthProvider.notifier).check(),
            icon: backend.isChecking
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.wifi_tethering_rounded, size: 18),
            label: Text(
              backend.isChecking ? 'Memeriksa...' : 'Periksa Koneksi',
            ),
          ),
        ),
      ],
    );
  }

  IconData _connectionIcon(BackendConnectionStatus status) {
    return switch (status) {
      BackendConnectionStatus.unknown => Icons.help_outline_rounded,
      BackendConnectionStatus.checking => Icons.sync_rounded,
      BackendConnectionStatus.connected => Icons.check_circle_outline_rounded,
      BackendConnectionStatus.unreachable => Icons.error_outline_rounded,
    };
  }

  ChipTone _connectionTone(BackendConnectionStatus status) {
    return switch (status) {
      BackendConnectionStatus.unknown => ChipTone.neutral,
      BackendConnectionStatus.checking => ChipTone.primary,
      BackendConnectionStatus.connected => ChipTone.success,
      BackendConnectionStatus.unreachable => ChipTone.danger,
    };
  }
}

class _MonitoringSection extends StatelessWidget {
  const _MonitoringSection({
    required this.monitoring,
    required this.totalDevices,
    required this.onCheck,
    required this.onOpenDevices,
  });

  final MonitoringState monitoring;
  final int totalDevices;
  final Future<void> Function() onCheck;
  final VoidCallback onOpenDevices;

  @override
  Widget build(BuildContext context) {
    final MonitoringStatus? status = monitoring.monitoring?.data;
    final MonitoringResult? result = status?.lastResult;

    return SectionCard(
      title: 'Monitoring perangkat',
      icon: Icons.sensors_outlined,
      trailing: status == null
          ? null
          : InfoChip(
              label: status.running ? 'Berjalan' : 'Tidak aktif',
              tone: status.running ? ChipTone.success : ChipTone.warning,
            ),
      children: <Widget>[
        if (status == null && monitoring.isLoading)
          const Row(
            children: <Widget>[
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: ComponentTheme.space8),
              Text('Memuat status monitoring...'),
            ],
          )
        else if (status == null) ...<Widget>[
          Text(
            monitoring.error == null
                ? 'Status monitoring belum tersedia dari backend.'
                : describeApiError(monitoring.error),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: ComponentTheme.space12),
        ] else ...<Widget>[
          InfoRow(
            label: 'Interval',
            value: _formatInterval(status.intervalSeconds),
          ),
          if (status.lastRunAt != null)
            InfoRow(
              label: 'Pemeriksaan terakhir',
              value: formatDateTime(status.lastRunAt!),
            ),
          InfoRow(label: 'Total perangkat', value: totalDevices.toString()),
          if (result != null) ...<Widget>[
            InfoRow(
              label: 'Terpantau',
              value: '${result.monitoredDevices} dari ${result.totalDevices}',
            ),
            InfoRow(
              label: 'Online / Offline',
              value: '${result.online} / ${result.offline}',
              valueColor: ColorTokens.success,
            ),
            InfoRow(
              label: 'Unknown',
              value: result.unknown.toString(),
              valueColor: ColorTokens.warning,
            ),
            InfoRow(
              label: 'Tidak didukung',
              value: result.unsupportedDevices.toString(),
            ),
          ] else
            const InfoRow(label: 'Hasil', value: 'Belum ada hasil pemeriksaan'),
        ],
        if (monitoring.error != null && status != null)
          Padding(
            padding: const EdgeInsets.only(bottom: ComponentTheme.space8),
            child: Text(
              describeApiError(monitoring.error),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: ColorTokens.warning),
            ),
          ),
        Wrap(
          spacing: ComponentTheme.space8,
          runSpacing: ComponentTheme.space8,
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: monitoring.isChecking ? null : onCheck,
              icon: monitoring.isChecking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow_rounded, size: 18),
              label: Text(
                monitoring.isChecking ? 'Memeriksa...' : 'Periksa Sekarang',
              ),
            ),
            TextButton.icon(
              onPressed: onOpenDevices,
              icon: const Icon(Icons.devices_other_outlined, size: 18),
              label: const Text('Kelola Perangkat'),
            ),
          ],
        ),
      ],
    );
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
}

class _ApiConfigSection extends ConsumerWidget {
  const _ApiConfigSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppConfig config = ref.watch(appConfigProvider);
    final String? problem = config.apiBaseUrlValidationError;

    return SectionCard(
      title: 'Konfigurasi API',
      icon: Icons.settings_ethernet_rounded,
      children: <Widget>[
        if (problem != null) ...<Widget>[
          Text(
            problem,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: ColorTokens.danger),
          ),
          const SizedBox(height: ComponentTheme.space8),
          Text(
            'Tetapkan saat menjalankan aplikasi, misalnya '
            '--dart-define=${AppConfig.apiBaseUrlDefine}=https://host-api',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: ComponentTheme.space12),
        ],
        InfoRow(
          label: 'Batas koneksi',
          value: '${config.connectTimeout.inSeconds} detik',
        ),
        InfoRow(
          label: 'Batas terima',
          value: '${config.receiveTimeout.inSeconds} detik',
        ),
        InfoRow(
          label: 'Batas kirim',
          value: '${config.sendTimeout.inSeconds} detik',
        ),
        const SizedBox(height: ComponentTheme.space4),
        Text(
          'Base URL hanya berasal dari konfigurasi build, tidak disimpan di '
          'source code maupun dapat diubah dari layar ini.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _AppInfoSection extends StatelessWidget {
  const _AppInfoSection();

  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      title: 'Aplikasi',
      icon: Icons.info_outline_rounded,
      children: <Widget>[
        InfoRow(label: 'Nama', value: AppConstants.appName),
        InfoRow(label: 'Versi', value: AppConstants.appVersion),
        InfoRow(label: 'Platform', value: AppConstants.platformLabel),
        InfoRow(label: 'Tema', value: 'Terang'),
        InfoRow(label: 'Bahasa', value: 'Indonesia'),
      ],
    );
  }
}

class _UnavailableSection extends StatelessWidget {
  const _UnavailableSection();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SectionCard(
      title: 'Belum tersedia',
      icon: Icons.link_off_rounded,
      trailing: const InfoChip(label: 'Menunggu API', tone: ChipTone.warning),
      children: <Widget>[
        Text(
          'Modul berikut belum diaktifkan karena kontrak endpoint backend-nya '
          'belum tersedia atau belum diverifikasi. Aplikasi tidak menampilkan '
          'data contoh untuk modul ini.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: ComponentTheme.space12),
        for (final String item in const <String>[
          'Energi/inverter — endpoint /api/v1/energy/* belum ada',
          'CCTV — endpoint katalog kamera dan sesi signaling belum ada',
          'Voice — endpoint unggah audio dan respons belum ada',
          'Akun, sesi, dan logout — kontrak autentikasi belum ditetapkan',
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: ComponentTheme.space8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.radio_button_unchecked,
                    size: 15,
                    color: ColorTokens.textSecondary,
                  ),
                ),
                const SizedBox(width: ComponentTheme.space8),
                Expanded(child: Text(item, style: textTheme.bodyMedium)),
              ],
            ),
          ),
      ],
    );
  }
}
