import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/component_theme.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/device_type.dart';
import '../../../shared/utils/error_message.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/device_model.dart';
import '../../../data/models/monitoring_model.dart';
import '../../../data/providers/device_control_provider.dart';
import '../../../data/providers/device_providers.dart';
import '../../../shared/widgets/elfan_brand.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/info_chip.dart';
import '../../../shared/widgets/section_card.dart';
import '../widgets/device_status.dart';
import 'device_detail_screen.dart';

/// Daftar perangkat ELFAN.
///
/// Seluruh angka dan status berasal dari backend aktual:
/// `GET /api/v1/devices` dan `GET /api/v1/monitoring/status`. Tidak ada
/// perangkat contoh maupun status yang ditebak.
class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  Future<void> _refreshAll(WidgetRef ref) async {
    await Future.wait(<Future<void>>[
      ref.read(deviceListProvider.notifier).refresh(),
      ref.read(monitoringProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DeviceListState deviceList = ref.watch(deviceListProvider);
    final MonitoringState monitoring = ref.watch(monitoringProvider);
    final double padding = Responsive.pagePadding(context);

    final bool initialLoading =
        deviceList.isLoading &&
        deviceList.devices.isEmpty &&
        deviceList.error == null;

    return Scaffold(
      appBar: ElfanAppBar(
        title: 'Perangkat',
        subtitle: 'Kelola perangkat & monitoring',
        actions: <Widget>[
          IconButton(
            onPressed: deviceList.isLoading ? null : () => _refreshAll(ref),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Muat Ulang',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ResponsiveContent(
          child: RefreshIndicator(
            onRefresh: () => _refreshAll(ref),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(padding, 20, padding, 28),
              children: <Widget>[
                _MonitoringCard(monitoring: monitoring),
                const SizedBox(height: ComponentTheme.space16),
                _DeviceListHeader(deviceList: deviceList),
                const SizedBox(height: ComponentTheme.space12),
                if (initialLoading)
                  const _InlineLoading(label: 'Memuat daftar perangkat...')
                else if (deviceList.error != null && deviceList.devices.isEmpty)
                  ErrorState(
                    title: 'Gagal memuat perangkat',
                    error: deviceList.error,
                    onRetry: () =>
                        ref.read(deviceListProvider.notifier).retry(),
                  )
                else if (deviceList.devices.isEmpty)
                  EmptyState(
                    icon: Icons.devices_other_outlined,
                    title: 'Belum ada perangkat terdaftar',
                    message:
                        'Backend belum mengembalikan perangkat. Aplikasi tidak '
                        'menampilkan perangkat contoh.',
                    footnote: 'ELFAN Mobile V2',
                    action: FilledButton.icon(
                      onPressed: () =>
                          ref.read(deviceListProvider.notifier).refresh(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Muat Ulang'),
                    ),
                  )
                else
                  _DeviceGroups(devices: deviceList.devices),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineLoading extends StatelessWidget {
  const _InlineLoading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ComponentTheme.space24),
      child: Column(
        children: <Widget>[
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: ComponentTheme.space12),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Ringkasan monitoring agregat dari `GET /api/v1/monitoring/status`.
///
/// Kartu tetap tampil walau `last_result` belum ada, sehingga pemeriksaan
/// manual pertama tetap dapat dijalankan dari layar ini.
class _MonitoringCard extends ConsumerWidget {
  const _MonitoringCard({required this.monitoring});

  final MonitoringState monitoring;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final MonitoringStatus? status = monitoring.monitoring?.data;
    final MonitoringResult? result = status?.lastResult;

    return SectionCard(
      title: 'Monitoring',
      icon: Icons.sensors_outlined,
      trailing: status == null
          ? null
          : InfoChip(
              label: status.running ? 'Berjalan' : 'Tidak aktif',
              icon: status.running
                  ? Icons.play_circle_outline_rounded
                  : Icons.pause_circle_outline_rounded,
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
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: ComponentTheme.space12),
        ] else ...<Widget>[
          Wrap(
            spacing: ComponentTheme.space8,
            runSpacing: ComponentTheme.space8,
            children: <Widget>[
              InfoChip(
                label: 'Interval ${_formatInterval(status.intervalSeconds)}',
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
          const SizedBox(height: ComponentTheme.space12),
          if (result == null)
            Text(
              'Belum ada hasil pemeriksaan monitoring.',
              style: textTheme.bodySmall,
            )
          else ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: _MonitorStat(
                    label: 'Total',
                    value: result.totalDevices,
                    color: ColorTokens.primary,
                  ),
                ),
                Expanded(
                  child: _MonitorStat(
                    label: 'Terpantau',
                    value: result.monitoredDevices,
                    color: ColorTokens.primary,
                  ),
                ),
                Expanded(
                  child: _MonitorStat(
                    label: 'Online',
                    value: result.online,
                    color: ColorTokens.success,
                  ),
                ),
                Expanded(
                  child: _MonitorStat(
                    label: 'Offline',
                    value: result.offline,
                    color: ColorTokens.danger,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ComponentTheme.space12),
            Wrap(
              spacing: ComponentTheme.space8,
              runSpacing: ComponentTheme.space8,
              children: <Widget>[
                InfoChip(
                  label: '${result.unknown} unknown',
                  icon: Icons.help_outline_rounded,
                  tone: ChipTone.warning,
                ),
                InfoChip(
                  label: '${result.unsupportedDevices} tidak didukung',
                  icon: Icons.block_outlined,
                  tone: ChipTone.neutral,
                ),
                if (result.checkedAt != null)
                  InfoChip(
                    label: 'Diperiksa ${formatClock(result.checkedAt!)}',
                    icon: Icons.schedule_rounded,
                    tone: ChipTone.neutral,
                  ),
              ],
            ),
          ],
        ],
        if (monitoring.error != null && status != null)
          Padding(
            padding: const EdgeInsets.only(top: ComponentTheme.space8),
            child: Text(
              describeApiError(monitoring.error),
              style: textTheme.bodySmall?.copyWith(color: ColorTokens.warning),
            ),
          ),
        const SizedBox(height: ComponentTheme.space12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: monitoring.isChecking
                ? null
                : () => ref.read(monitoringProvider.notifier).check(),
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

class _MonitorStat extends StatelessWidget {
  const _MonitorStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          value.toString(),
          style: textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: textTheme.labelSmall),
      ],
    );
  }
}

/// Header daftar perangkat.
///
/// Memakai [Wrap] agar chip ringkasan tidak overflow pada layar sempit.
class _DeviceListHeader extends StatelessWidget {
  const _DeviceListHeader({required this.deviceList});

  final DeviceListState deviceList;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ComponentTheme.space20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.devices_other_rounded,
                  size: 20,
                  color: ColorTokens.primary,
                ),
                const SizedBox(width: ComponentTheme.space8),
                Expanded(
                  child: Text('Daftar perangkat', style: textTheme.titleMedium),
                ),
                InfoChip(
                  label: '${deviceList.total} perangkat',
                  icon: Icons.list_alt_rounded,
                  tone: ChipTone.primary,
                ),
              ],
            ),
            const SizedBox(height: ComponentTheme.space12),
            Wrap(
              spacing: ComponentTheme.space8,
              runSpacing: ComponentTheme.space8,
              children: <Widget>[
                InfoChip(
                  label: '${deviceList.supportedDevices} didukung',
                  icon: Icons.check_circle_outline_rounded,
                  tone: ChipTone.success,
                ),
                if (deviceList.unsupportedCount > 0)
                  InfoChip(
                    label: '${deviceList.unsupportedCount} perlu verifikasi',
                    icon: Icons.verified_user_outlined,
                    tone: ChipTone.warning,
                  ),
                if (deviceList.isLoading && deviceList.devices.isNotEmpty)
                  const InfoChip(
                    label: 'Menyegarkan...',
                    icon: Icons.sync_rounded,
                    tone: ChipTone.info,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceGroups extends StatelessWidget {
  const _DeviceGroups({required this.devices});

  final List<Device> devices;

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Device>> grouped = <String, List<Device>>{};
    for (final Device device in devices) {
      final String key = device.location.isEmpty
          ? 'Tanpa lokasi'
          : device.location;
      grouped.putIfAbsent(key, () => <Device>[]).add(device);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final MapEntry<String, List<Device>> entry in grouped.entries)
          _DeviceGroup(title: entry.key, devices: entry.value),
      ],
    );
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
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: ColorTokens.primary,
              ),
              const SizedBox(width: ComponentTheme.space8),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InfoChip(label: '${devices.length}', tone: ChipTone.neutral),
            ],
          ),
        ),
        for (final Device device in devices) _DeviceTile(device: device),
      ],
    );
  }
}

class _DeviceTile extends ConsumerWidget {
  const _DeviceTile({required this.device});

  final Device device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DeviceControlState control = ref.watch(deviceControlProvider);
    final MonitoringDeviceResult? monitoring = ref.watch(
      deviceMonitoringProvider(device.id),
    );
    final List<DeviceChannel> channels =
        device.channels ?? const <DeviceChannel>[];
    final DeviceTypeInfo typeInfo = deviceTypeInfoFor(
      category: device.category,
      type: device.type,
      channelCount: channels.length,
    );

    final bool isControlling =
        control.isControlling && control.pendingCommand?.deviceId == device.id;
    final String? controlBlockedReason = _controlBlockedReason(device);

    return Card(
      margin: const EdgeInsets.only(bottom: ComponentTheme.space8),
      child: InkWell(
        // Detail tetap dapat dibuka untuk perangkat nonaktif/perlu verifikasi;
        // hanya kontrolnya yang dinonaktifkan.
        onTap: () => DeviceDetailScreen.navigate(context, device.id),
        borderRadius: BorderRadius.circular(ComponentTheme.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(ComponentTheme.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: ColorTokens.primarySoft,
                      borderRadius: BorderRadius.circular(
                        ComponentTheme.radiusMedium,
                      ),
                    ),
                    child: Icon(
                      typeInfo.icon,
                      size: 22,
                      color: ColorTokens.primary,
                    ),
                  ),
                  const SizedBox(width: ComponentTheme.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          device.name,
                          style: textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: ComponentTheme.space4),
                        Wrap(
                          spacing: ComponentTheme.space4,
                          runSpacing: ComponentTheme.space4,
                          children: <Widget>[
                            InfoChip(
                              label: typeInfo.label,
                              icon: typeInfo.icon,
                              tone: ChipTone.primary,
                            ),
                            if (monitoring != null)
                              InfoChip(
                                label: connectionLabel(
                                  monitoring.connectionStatus,
                                ),
                                icon: Icons.wifi_tethering_rounded,
                                tone: connectionTone(
                                  monitoring.connectionStatus,
                                ),
                              ),
                            if (!device.enabled)
                              const InfoChip(
                                label: 'Nonaktif',
                                icon: Icons.block_outlined,
                                tone: ChipTone.warning,
                              ),
                            if (device.isVerificationRequired)
                              const InfoChip(
                                label: 'Perlu verifikasi',
                                icon: Icons.verified_user_outlined,
                                tone: ChipTone.danger,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: ComponentTheme.space8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: ColorTokens.textSecondary,
                  ),
                ],
              ),
              if (device.isMultiChannel && monitoring != null) ...<Widget>[
                const SizedBox(height: ComponentTheme.space12),
                Wrap(
                  spacing: ComponentTheme.space4,
                  runSpacing: ComponentTheme.space4,
                  children: <Widget>[
                    for (final MonitoringChannelResult channel
                        in monitoring.channels)
                      ChannelStateChip(
                        name: channel.name,
                        state: channel.state,
                      ),
                  ],
                ),
              ],
              const SizedBox(height: ComponentTheme.space12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      controlBlockedReason ??
                          (channels.isEmpty
                              ? 'Kontrol kanal belum tersedia'
                              : '${channels.length} kanal'),
                      style: textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isControlling)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ComponentTheme.space12,
                      ),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    TextButton.icon(
                      onPressed: controlBlockedReason == null
                          ? () => showDialog<void>(
                              context: context,
                              builder: (BuildContext context) =>
                                  _DeviceControlDialog(device: device),
                            )
                          : null,
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: const Text('Kontrol'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Alasan kontrol tidak boleh dikirim, atau `null` jika aman.
  ///
  /// Kontrol hanya diaktifkan bila backend menyediakan `switch_dp` per kanal
  /// dan perangkat tidak ditandai perlu verifikasi/nonaktif.
  String? _controlBlockedReason(Device device) {
    if (device.isVerificationRequired) {
      return 'Perlu verifikasi sebelum dikontrol.';
    }
    if (!device.enabled) {
      return 'Dinonaktifkan di backend.';
    }
    if (!device.hasChannels) {
      return 'DP kontrol kanal belum tersedia dari backend.';
    }
    return null;
  }
}

/// Dialog kontrol perangkat.
///
/// Berupa [ConsumerWidget] agar status pengiriman perintah benar-benar
/// diperbarui (sebelumnya `ref.watch` dipanggil di dalam callback sehingga
/// dialog tidak pernah menampilkan progres).
class _DeviceControlDialog extends ConsumerWidget {
  const _DeviceControlDialog({required this.device});

  final Device device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DeviceControlState control = ref.watch(deviceControlProvider);
    final MonitoringDeviceResult? monitoring = ref.watch(
      deviceMonitoringProvider(device.id),
    );
    final List<DeviceChannel> channels =
        device.channels ?? const <DeviceChannel>[];
    final Map<String, MonitoringChannelResult> statesByDp =
        <String, MonitoringChannelResult>{
          for (final MonitoringChannelResult channel
              in monitoring?.channels ?? const <MonitoringChannelResult>[])
            channel.switchDp: channel,
        };
    final DeviceTypeInfo typeInfo = deviceTypeInfoFor(
      category: device.category,
      type: device.type,
      channelCount: channels.length,
    );
    final bool busy =
        control.isControlling && control.pendingCommand?.deviceId == device.id;

    Future<void> run(Future<void> Function() action) async {
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      try {
        await action();
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Perintah terkirim ke backend. Kondisi terbaru muncul setelah '
              'monitoring berikutnya atau saat detail dimuat ulang.',
            ),
          ),
        );
      } catch (error) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              describeApiError(error, fallback: 'Perintah gagal dikirim.'),
            ),
            backgroundColor: ColorTokens.danger,
          ),
        );
      }
    }

    return AlertDialog(
      title: const Text('Kontrol perangkat'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(device.name, style: textTheme.titleSmall),
            const SizedBox(height: ComponentTheme.space8),
            Wrap(
              spacing: ComponentTheme.space4,
              runSpacing: ComponentTheme.space4,
              children: <Widget>[
                InfoChip(
                  label: typeInfo.label,
                  icon: typeInfo.icon,
                  tone: ChipTone.primary,
                ),
                if (monitoring != null)
                  InfoChip(
                    label: connectionLabel(monitoring.connectionStatus),
                    icon: Icons.wifi_tethering_rounded,
                    tone: connectionTone(monitoring.connectionStatus),
                  ),
              ],
            ),
            const SizedBox(height: ComponentTheme.space16),
            if (channels.length > 1) ...<Widget>[
              for (final (int index, DeviceChannel channel) in channels.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: ComponentTheme.space8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(channel.name, style: textTheme.bodyMedium),
                            Text(
                              'Kondisi: ${channelStateLabel(statesByDp[channel.switchDp]?.state)}',
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: busy
                            ? null
                            : () => run(
                                () => ref
                                    .read(deviceControlProvider.notifier)
                                    .setChannelState(device, index, true),
                              ),
                        child: const Text('ON'),
                      ),
                      TextButton(
                        onPressed: busy
                            ? null
                            : () => run(
                                () => ref
                                    .read(deviceControlProvider.notifier)
                                    .setChannelState(device, index, false),
                              ),
                        child: const Text('OFF'),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: ComponentTheme.space8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy
                          ? null
                          : () => run(
                              () => ref
                                  .read(deviceControlProvider.notifier)
                                  .turnAllOn(device),
                            ),
                      child: const Text('Semua ON'),
                    ),
                  ),
                  const SizedBox(width: ComponentTheme.space12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy
                          ? null
                          : () => run(
                              () => ref
                                  .read(deviceControlProvider.notifier)
                                  .turnAllOff(device),
                            ),
                      child: const Text('Semua OFF'),
                    ),
                  ),
                ],
              ),
            ] else ...<Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: busy
                          ? null
                          : () => run(
                              () => ref
                                  .read(deviceControlProvider.notifier)
                                  .turnOn(device),
                            ),
                      icon: const Icon(Icons.power_settings_new, size: 18),
                      label: const Text('Nyalakan'),
                    ),
                  ),
                  const SizedBox(width: ComponentTheme.space12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: busy
                          ? null
                          : () => run(
                              () => ref
                                  .read(deviceControlProvider.notifier)
                                  .turnOff(device),
                            ),
                      icon: const Icon(Icons.power_off, size: 18),
                      label: const Text('Matikan'),
                    ),
                  ),
                ],
              ),
            ],
            if (busy) ...<Widget>[
              const SizedBox(height: ComponentTheme.space16),
              const Row(
                children: <Widget>[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: ComponentTheme.space8),
                  Text('Mengirim perintah...'),
                ],
              ),
            ],
            const SizedBox(height: ComponentTheme.space12),
            Text(
              'Perintah dikirim melalui backend. Status kanal tidak diubah '
              'secara lokal sebelum backend mengonfirmasi.',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}
