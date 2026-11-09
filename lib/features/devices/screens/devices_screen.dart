import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/component_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/device_model.dart';
import '../../../data/models/monitoring_model.dart';
import '../../../data/providers/device_providers.dart';
import '../../../data/providers/device_control_provider.dart';
import '../../../shared/widgets/elfan_brand.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/info_chip.dart';
import '../../../data/services/api_exception.dart';
import 'device_detail_screen.dart';

/// Daftar dan detail perangkat ELFAN.
///
/// Menampilkan data dari backend aktual, bukan dummy.
class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DeviceListState deviceState = ref.watch(deviceListProvider);
    final MonitoringState monitoringState = ref.watch(monitoringProvider);

    return Scaffold(
      appBar: const ElfanAppBar(
        title: 'Perangkat',
        subtitle: 'Kelola perangkat & monitoring',
      ),
      body: SafeArea(
        top: false,
        child: ResponsiveContent(
          child: deviceState.isLoading && monitoringState.isLoading
              ? const _LoadingView()
              : deviceState.isEmpty && monitoringState.monitoring == null
              ? _EmptyView(
                  onRefresh: () =>
                      ref.read(deviceListProvider.notifier).refresh(),
                )
              : ListView(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.pagePadding(context),
                    20,
                    Responsive.pagePadding(context),
                    28,
                  ),
                  children: <Widget>[
                    if (monitoringState.monitoring?.data != null &&
                        monitoringState.monitoring!.data!.lastResult != null)
                      _MonitoringSummaryCard(
                        status: monitoringState.monitoring!.data!,
                        isChecking: monitoringState.isChecking,
                        lastRefreshed: monitoringState.lastRefreshed,
                        onCheck: () {
                          if (!monitoringState.isChecking) {
                            ref.read(monitoringProvider.notifier).check();
                          }
                        },
                      ),
                    const SizedBox(height: 16),
                    _DeviceListHeader(
                      total: deviceState.total,
                      supported: deviceState.supportedDevices,
                      unsupported: deviceState.unsupportedCount,
                      isLoading: deviceState.isLoading,
                      onRefresh: () =>
                          ref.read(deviceListProvider.notifier).refresh(),
                    ),
                    if (deviceState.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (deviceState.error != null &&
                        deviceState.devices.isEmpty)
                      _ErrorView(
                        error: deviceState.error!,
                        onRetry: () =>
                            ref.read(deviceListProvider.notifier).retry(),
                      )
                    else
                      _DeviceList(devices: deviceState.devices),
                  ],
                ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final double padding = Responsive.pagePadding(context);
    return Scaffold(
      appBar: const ElfanAppBar(title: 'Perangkat', subtitle: 'Memuat...'),
      body: SafeArea(
        top: false,
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.fromLTRB(padding, 20, padding, 28),
            children: const <Widget>[
              Center(child: CircularProgressIndicator()),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final double padding = Responsive.pagePadding(context);
    return Scaffold(
      appBar: const ElfanAppBar(
        title: 'Perangkat',
        subtitle: 'Daftar perangkat',
      ),
      body: SafeArea(
        top: false,
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.fromLTRB(padding, 20, padding, 28),
            children: <Widget>[
              EmptyState(
                icon: Icons.devices_other_outlined,
                title: 'Belum ada data perangkat',
                message:
                    'Daftar perangkat akan diambil dari endpoint backend '
                    'yang sudah diverifikasi. Aplikasi tidak menampilkan '
                    'perangkat contoh.',
                footnote: 'ELFAN Mobile V2',
                action: FilledButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Muat Ulang'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final double padding = Responsive.pagePadding(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 0, padding, 20),
      child: EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Gagal memuat perangkat',
        message: _getMessage(error),
        footnote: 'Coba lagi atau periksa koneksi internet.',
        action: FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Coba Lagi'),
        ),
      ),
    );
  }

  String _getMessage(Object e) {
    if (e is ApiException) return e.userMessage;
    if (e is String) return e;
    final String message = e.toString();
    if (message.contains('configuration')) {
      return 'Konfigurasi API belum siap. Hubungi administrator.';
    }
    if (message.contains('timeout') ||
        message.contains('Tidak dapat terhubung')) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi Anda.';
    }
    if (message.contains('server')) {
      return 'Server mengalami gangguan. Coba lagi nanti.';
    }
    return 'Terjadi kesalahan: ${message.split('\n').first}';
  }
}

class _MonitoringSummaryCard extends StatelessWidget {
  const _MonitoringSummaryCard({
    required this.status,
    required this.isChecking,
    required this.lastRefreshed,
    required this.onCheck,
  });

  /// Status monitoring agregat dari backend (`running`, `last_result`, ...).
  final MonitoringStatus status;
  final bool isChecking;
  final DateTime? lastRefreshed;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final MonitoringResult? monitoring = status.lastResult;
    final DateTime? lastChecked = monitoring?.checkedAt ?? lastRefreshed;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  status.running ? Icons.speed : Icons.slow_motion_video,
                  size: 20,
                  color: ColorTokens.primary,
                ),
                const SizedBox(width: 8),
                Text('Monitoring', style: textTheme.titleMedium),
                const Spacer(),
                if (status.running)
                  InfoChip(
                    label: 'Sedang berjalan',
                    icon: Icons.check_circle_outline_rounded,
                    tone: ChipTone.success,
                  )
                else
                  InfoChip(
                    label: 'Tidak aktif',
                    icon: Icons.pause_circle_outline_rounded,
                    tone: ChipTone.warning,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                InfoChip(
                  label: 'Interval ${_formatInterval(status.intervalSeconds)}',
                  icon: Icons.timer_outlined,
                  tone: ChipTone.primary,
                ),
                if (status.lastRunAt != null)
                  InfoChip(
                    label: 'Terakhir ${_formatDateTime(status.lastRunAt!)}',
                    icon: Icons.access_time,
                    tone: ChipTone.neutral,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: _MonitorStatItem(
                    label: 'Total',
                    value: (monitoring?.totalDevices ?? 0).toString(),
                  ),
                ),
                Container(width: 1, height: 32, color: ColorTokens.border),
                Expanded(
                  child: _MonitorStatItem(
                    label: 'Terpantau',
                    value: (monitoring?.monitoredDevices ?? 0).toString(),
                  ),
                ),
                Container(width: 1, height: 32, color: ColorTokens.border),
                Expanded(
                  child: _MonitorStatItem(
                    label: 'Supported',
                    value: (monitoring?.supportedDevices ?? 0).toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: _MonitorConnectionStat(
                    label: 'Online',
                    count: monitoring?.online ?? 0,
                    color: ColorTokens.success,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MonitorConnectionStat(
                    label: 'Offline',
                    count: monitoring?.offline ?? 0,
                    color: ColorTokens.danger,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MonitorConnectionStat(
                    label: 'Unknown',
                    count: monitoring?.unknown ?? 0,
                    color: ColorTokens.warning,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MonitorConnectionStat(
                    label: 'Unsupported',
                    count: monitoring?.unsupportedDevices ?? 0,
                    color: ColorTokens.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                if (lastChecked != null) ...<Widget>[
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: ColorTokens.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Terakhir: ${_formatDateTime(lastChecked)}',
                    style: textTheme.labelSmall,
                  ),
                  const SizedBox(width: 16),
                ],
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: isChecking ? null : onCheck,
                  icon: isChecking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(isChecking ? 'Memeriksa...' : 'Periksa Sekarang'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
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

class _MonitorStatItem extends StatelessWidget {
  const _MonitorStatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            color: ColorTokens.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: textTheme.labelSmall),
      ],
    );
  }
}

class _MonitorConnectionStat extends StatelessWidget {
  const _MonitorConnectionStat({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        Text(
          count.toString(),
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: textTheme.labelSmall?.copyWith(color: color)),
      ],
    );
  }
}

class _DeviceListHeader extends StatelessWidget {
  const _DeviceListHeader({
    required this.total,
    required this.supported,
    required this.unsupported,
    required this.isLoading,
    required this.onRefresh,
  });

  final int total;
  final int supported;
  final int unsupported;
  final bool isLoading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: <Widget>[
        const Icon(Icons.devices_other, size: 20, color: ColorTokens.primary),
        const SizedBox(width: 8),
        Text('Total Perangkat', style: textTheme.titleSmall),
        const Spacer(),
        InfoChip(
          label: '$total perangkat',
          icon: Icons.list_alt_rounded,
          tone: ChipTone.primary,
        ),
        const SizedBox(width: 8),
        InfoChip(
          label: '$supported didukung',
          icon: Icons.check_circle_outline_rounded,
          tone: ChipTone.success,
        ),
        if (unsupported > 0) ...<Widget>[
          const SizedBox(width: 8),
          InfoChip(
            label: '$unsupported tidak didukung',
            icon: Icons.warning_rounded,
            tone: ChipTone.warning,
          ),
        ],
        const SizedBox(width: 16),
        IconButton(
          onPressed: isLoading ? null : onRefresh,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Muat Ulang',
        ),
      ],
    );
  }
}

class _DeviceList extends StatelessWidget {
  const _DeviceList({required this.devices});

  final List<Device> devices;

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return const EmptyState(
        icon: Icons.devices_other_outlined,
        title: 'Belum ada perangkat terdaftar',
        message:
            'Daftar perangkat akan muncul di sini setelah tersambung ke backend.',
        footnote: 'ELFAN Mobile V2',
      );
    }

    // Kelompokkan perangkat berdasarkan lokasi
    final grouped = <String, List<Device>>{};
    for (final device in devices) {
      final key = device.location.isEmpty ? 'Tanpa Lokasi' : device.location;
      grouped.putIfAbsent(key, () => []).add(device);
    }

    final Widget children = ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entries = grouped.entries.elementAt(index);
        return _DeviceGroup(title: entries.key, devices: entries.value);
      },
    );

    return children;
  }
}

class _DeviceGroup extends StatelessWidget {
  const _DeviceGroup({required this.title, required this.devices});

  final String title;
  final List<Device> devices;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: ColorTokens.primary,
              ),
              const SizedBox(width: 8),
              Text(title, style: textTheme.titleMedium),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: ColorTokens.primarySoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${devices.length}',
                  style: textTheme.labelSmall?.copyWith(
                    color: ColorTokens.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            return _DeviceTile(device: device);
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _DeviceTile extends ConsumerWidget {
  const _DeviceTile({required this.device});

  final Device device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlState = ref.watch(deviceControlProvider);
    final isControlling = controlState.pendingCommand?.deviceId == device.id;

    final deviceTypeChip = _getTypeChip(device.type, device.category);
    final MonitoringDeviceResult? monitoring = ref.watch(
      deviceMonitoringProvider(device.id),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: device.isVerificationRequired
            ? null
            : () => DeviceDetailScreen.navigate(context, device.id),
        borderRadius: BorderRadius.circular(ComponentTheme.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              // Icon perangkat
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: deviceTypeChip.tone == ChipTone.success
                      ? ColorTokens.successSoft
                      : ColorTokens.background,
                  borderRadius: BorderRadius.circular(
                    ComponentTheme.radiusMedium,
                  ),
                  border: Border.all(
                    color: deviceTypeChip.tone == ChipTone.success
                        ? ColorTokens.success
                        : ColorTokens.border,
                  ),
                ),
                child: Icon(
                  _getIconForDevice(device),
                  color: deviceTypeChip.tone == ChipTone.success
                      ? ColorTokens.success
                      : ColorTokens.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              // Informasi perangkat
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      device.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        InfoChip(
                          label: deviceTypeChip.label,
                          icon: deviceTypeChip.icon,
                          tone: deviceTypeChip.tone,
                        ),
                        if (monitoring != null)
                          InfoChip(
                            label: _connectionLabel(monitoring),
                            icon: Icons.wifi_tethering_rounded,
                            tone: _connectionTone(monitoring),
                          ),
                        if (!device.enabled)
                          InfoChip(
                            label: 'Nonaktif',
                            icon: Icons.block_outlined,
                            tone: ChipTone.warning,
                          ),
                        if (device.isVerificationRequired)
                          InfoChip(
                            label: 'Verifikasi',
                            icon: Icons.verified_user_rounded,
                            tone: ChipTone.danger,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Channel indicator & kontrol
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  if (device.isMultiChannel && device.channels != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ColorTokens.primarySoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.expand_more,
                            size: 16,
                            color: ColorTokens.primaryDark,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${device.channels!.length} kanal',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: ColorTokens.primaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (isControlling)
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      onPressed: device.isVerificationRequired
                          ? null
                          : () => _showControlDialog(context, ref, device),
                      icon: const Icon(Icons.tune),
                      tooltip: 'Kontrol Perangkat',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _connectionLabel(MonitoringDeviceResult monitoring) {
    return monitoring.connectionStatus.displayName.toUpperCase();
  }

  ChipTone _connectionTone(MonitoringDeviceResult monitoring) {
    return switch (monitoring.connectionStatus) {
      ConnectionStatus.online => ChipTone.success,
      ConnectionStatus.offline => ChipTone.danger,
      ConnectionStatus.unknown => ChipTone.warning,
    };
  }

  _DeviceTypeChip _getTypeChip(String type, String category) {
    final categoryLower = category.toLowerCase();
    final typeLower = type.toLowerCase();

    if (categoryLower == 'cz' ||
        typeLower.contains('plug') ||
        typeLower.contains('socket')) {
      return _DeviceTypeChip(
        label: 'Smart Plug',
        icon: Icons.electrical_services_rounded,
        tone: ChipTone.primary,
      );
    }
    if (categoryLower == 'kg' || typeLower.contains('switch')) {
      if (device.isMultiChannel) {
        return _DeviceTypeChip(
          label: 'Multi Switch',
          icon: Icons.thermostat_rounded,
          tone: ChipTone.primary,
        );
      }
      return _DeviceTypeChip(
        label: 'Smart Switch',
        icon: Icons.toggle_on,
        tone: ChipTone.primary,
      );
    }
    if (categoryLower == 'tdq') {
      return _DeviceTypeChip(
        label: 'Smart Plug+',
        icon: Icons.air,
        tone: ChipTone.primary,
      );
    }
    if (categoryLower == 'wnykq') {
      return _DeviceTypeChip(
        label: 'IR Remote',
        icon: Icons.bluetooth_audio_rounded,
        tone: ChipTone.primary,
      );
    }
    if (categoryLower == 'qt') {
      return _DeviceTypeChip(
        label: 'IR Sub-device',
        icon: Icons.gesture_rounded,
        tone: ChipTone.primary,
      );
    }

    return _DeviceTypeChip(
      label: _capitalize(type),
      icon: Icons.device_hub,
      tone: ChipTone.neutral,
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  IconData _getIconForDevice(Device device) {
    final categoryLower = device.category.toLowerCase();
    if (categoryLower == 'cz' || categoryLower == 'tdq') {
      return Icons.electrical_services_rounded;
    }
    if (categoryLower == 'kg') {
      return Icons.lightbulb_rounded;
    }
    if (categoryLower == 'wnykq') {
      return Icons.bluetooth_audio_rounded;
    }
    if (categoryLower == 'qt') {
      return Icons.gesture_rounded;
    }
    return Icons.device_hub;
  }

  void _showControlDialog(BuildContext context, WidgetRef ref, Device device) {
    if (device.isVerificationRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Perangkat ini memerlukan verifikasi sebelum dikontrol.',
          ),
          backgroundColor: ColorTokens.danger,
        ),
      );
      return;
    }

    final DeviceControlState controlState = ref.watch(deviceControlProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kontrol Perangkat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(device.name, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(
              'Device ID: ${device.safeDisplayId}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (device.isMultiChannel && device.channels != null) ...<Widget>[
              const SizedBox(height: 16),
              const Text(
                'Kontrol per kanal:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: device.channels!.asMap().entries.map((entry) {
                  final channel = entry.value;
                  return Tooltip(
                    message: channel.isOn
                        ? 'Kondisi terakhir: ON'
                        : channel.isOff
                        ? 'Kondisi terakhir: OFF'
                        : 'Kondisi belum tersedia dari backend',
                    child: Chip(
                      avatar: Icon(
                        channel.isOn
                            ? Icons.circle
                            : channel.isOff
                            ? Icons.circle_outlined
                            : Icons.help_outline_rounded,
                        color: channel.isOn
                            ? ColorTokens.success
                            : channel.isOff
                            ? ColorTokens.textSecondary
                            : ColorTokens.warning,
                        size: 12,
                      ),
                      label: Text('Kanal ${entry.key + 1}: ${channel.name}'),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            if (controlState.isControlling)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(width: 8),
                  Text('Mengirim perintah...'),
                ],
              ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: controlState.isControlling
                ? null
                : () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: controlState.isControlling
                ? null
                : device.isMultiChannel
                ? () async {
                    await ref
                        .read(deviceControlProvider.notifier)
                        .turnAllOn(device);
                    if (context.mounted) Navigator.of(context).pop();
                  }
                : () async {
                    await ref
                        .read(deviceControlProvider.notifier)
                        .turnOn(device);
                    if (context.mounted) Navigator.of(context).pop();
                  },
            child: const Text('Nyalakan Semua'),
          ),
          OutlinedButton(
            onPressed: controlState.isControlling
                ? null
                : device.isMultiChannel
                ? () async {
                    await ref
                        .read(deviceControlProvider.notifier)
                        .turnAllOff(device);
                    if (context.mounted) Navigator.of(context).pop();
                  }
                : () async {
                    await ref
                        .read(deviceControlProvider.notifier)
                        .turnOff(device);
                    if (context.mounted) Navigator.of(context).pop();
                  },
            child: const Text('Matikan Semua'),
          ),
        ],
      ),
    );
  }
}

class _DeviceTypeChip {
  final String label;
  final IconData icon;
  final ChipTone tone;

  _DeviceTypeChip({
    required this.label,
    required this.icon,
    required this.tone,
  });
}
