import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/component_theme.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/device_type.dart';
import '../../../shared/utils/error_message.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/device_model.dart';
import '../../../data/models/device_state_model.dart';
import '../../../data/models/monitoring_model.dart';
import '../../../data/providers/device_control_provider.dart';
import '../../../data/providers/device_providers.dart';
import '../../../shared/widgets/elfan_brand.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/info_chip.dart';
import '../../../shared/widgets/info_row.dart';
import '../../../shared/widgets/section_card.dart';
import '../widgets/device_status.dart';

/// Halaman detail perangkat.
///
/// Sumber data:
/// - `GET /api/v1/devices/{logical_id}` untuk informasi perangkat,
/// - `GET /api/v1/devices/{logical_id}/state` untuk status koneksi dan state
///   kanal terbaru.
///
/// Status koneksi dan state kanal ditampilkan terpisah. Kondisi yang tidak
/// dikirim backend ditulis `belum tersedia`, tidak ditebak menjadi OFF.
class DeviceDetailScreen extends ConsumerWidget {
  const DeviceDetailScreen({super.key, required this.deviceId});

  final String deviceId;

  static void navigate(BuildContext context, String deviceId) {
    context.pushNamed(
      AppRouteNames.deviceDetail,
      pathParameters: <String, String>{'deviceId': deviceId},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DeviceDetailState detail = ref.watch(deviceDetailProvider(deviceId));
    final DeviceStateViewState stateView = ref.watch(
      deviceStateProvider(deviceId),
    );
    final double padding = Responsive.pagePadding(context);

    final Device? device = detail.device;

    if (device == null) {
      return Scaffold(
        appBar: const ElfanAppBar(
          title: 'Detail Perangkat',
          subtitle: 'Perangkat',
          showBrand: false,
        ),
        body: SafeArea(
          top: false,
          child: ResponsiveContent(
            child: ListView(
              padding: EdgeInsets.fromLTRB(padding, 20, padding, 28),
              children: <Widget>[
                if (detail.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: ComponentTheme.space24,
                    ),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (detail.error != null)
                  ErrorState(
                    title: 'Gagal memuat detail',
                    error: detail.error,
                    onRetry: () => ref
                        .read(deviceDetailProvider(deviceId).notifier)
                        .refresh(deviceId),
                  )
                else
                  const EmptyState(
                    icon: Icons.devices_other_outlined,
                    title: 'Perangkat tidak ditemukan',
                    message:
                        'Perangkat dengan ID tersebut tidak tersedia pada '
                        'respons backend.',
                    footnote: 'ELFAN Mobile V2',
                  ),
              ],
            ),
          ),
        ),
      );
    }

    final List<DeviceChannel> channels =
        device.channels ?? const <DeviceChannel>[];
    final DeviceTypeInfo typeInfo = deviceTypeInfoFor(
      category: device.category,
      type: device.type,
      channelCount: channels.length,
    );
    final Map<String, MonitoringChannelResult> statesByDp =
        <String, MonitoringChannelResult>{
          for (final MonitoringChannelResult channel
              in stateView.snapshot?.channels ??
                  const <MonitoringChannelResult>[])
            channel.switchDp: channel,
        };
    final String? controlBlockedReason = _controlBlockedReason(device);

    Future<void> refreshAll() async {
      await Future.wait(<Future<void>>[
        ref.read(deviceDetailProvider(deviceId).notifier).refresh(deviceId),
        ref.read(deviceStateProvider(deviceId).notifier).refresh(),
      ]);
    }

    return Scaffold(
      appBar: ElfanAppBar(
        title: device.name,
        subtitle: device.location.isEmpty ? 'Tanpa lokasi' : device.location,
        showBrand: false,
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
                SectionCard(
                  title: 'Informasi perangkat',
                  icon: Icons.info_outline_rounded,
                  trailing: InfoChip(
                    label: typeInfo.label,
                    icon: typeInfo.icon,
                    tone: ChipTone.primary,
                  ),
                  children: <Widget>[
                    InfoRow(label: 'Nama', value: device.name),
                    InfoRow(
                      label: 'Lokasi',
                      value: device.location.isEmpty
                          ? 'Belum ditentukan'
                          : device.location,
                    ),
                    InfoRow(
                      label: 'Kategori',
                      value: device.category.isEmpty
                          ? 'Tidak dikirim backend'
                          : device.category,
                    ),
                    InfoRow(
                      label: 'Status perangkat',
                      value: device.enabled ? 'Aktif' : 'Dinonaktifkan',
                      valueColor: device.enabled
                          ? ColorTokens.success
                          : ColorTokens.warning,
                    ),
                    if (device.isVerificationRequired)
                      const InfoRow(
                        label: 'Verifikasi',
                        value: 'Diperlukan sebelum kontrol',
                        valueColor: ColorTokens.danger,
                      ),
                    if (device.statusMode != null)
                      InfoRow(label: 'Mode status', value: device.statusMode!),
                    if (device.note != null)
                      InfoRow(label: 'Catatan', value: device.note!),
                  ],
                ),
                const SizedBox(height: ComponentTheme.space16),
                _DeviceStateSection(
                  view: stateView,
                  onRetry: () => ref
                      .read(deviceStateProvider(deviceId).notifier)
                      .refresh(),
                ),
                const SizedBox(height: ComponentTheme.space16),
                SectionCard(
                  title: channels.isEmpty
                      ? 'Kanal'
                      : 'Kanal (${channels.length})',
                  icon: Icons.tune_rounded,
                  children: <Widget>[
                    if (channels.isEmpty)
                      Text(
                        'Backend tidak mengirim daftar kanal untuk perangkat '
                        'ini, sehingga kontrol ON/OFF tidak ditampilkan.',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      for (final (int index, DeviceChannel channel)
                          in channels.indexed)
                        _ChannelRow(
                          index: index,
                          channel: channel,
                          state: statesByDp[channel.switchDp]?.state,
                          enabled: controlBlockedReason == null,
                          onTap: () => showDialog<void>(
                            context: context,
                            builder: (BuildContext context) =>
                                _ChannelControlDialog(
                                  device: device,
                                  channelIndex: index,
                                ),
                          ),
                        ),
                  ],
                ),
                const SizedBox(height: ComponentTheme.space16),
                _ControlSection(
                  device: device,
                  blockedReason: controlBlockedReason,
                  onTurnOn: () =>
                      ref.read(deviceControlProvider.notifier).turnOn(device),
                  onTurnOff: () =>
                      ref.read(deviceControlProvider.notifier).turnOff(device),
                  onCompleted: refreshAll,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Alasan kontrol tidak boleh dikirim, atau `null` jika aman.
  String? _controlBlockedReason(Device device) {
    if (device.isVerificationRequired) {
      return 'Perangkat ini memerlukan verifikasi sebelum dikontrol.';
    }
    if (!device.enabled) {
      return 'Perangkat dinonaktifkan di backend, sehingga kontrol diblokir.';
    }
    if (!device.hasChannels) {
      return 'DP kontrol kanal belum tersedia dari backend.';
    }
    return null;
  }
}

class _ChannelRow extends StatelessWidget {
  const _ChannelRow({
    required this.index,
    required this.channel,
    required this.state,
    required this.enabled,
    required this.onTap,
  });

  final int index;
  final DeviceChannel channel;
  final ChannelState? state;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(ComponentTheme.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: ComponentTheme.space8,
          horizontal: ComponentTheme.space4,
        ),
        child: Row(
          children: <Widget>[
            Icon(channelIcon(state), size: 22, color: channelIconColor(state)),
            const SizedBox(width: ComponentTheme.space8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${index + 1}. ${channel.name}',
                    style: textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Kondisi: ${channelStateLabel(state)}',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (enabled)
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: ColorTokens.textSecondary,
              )
            else
              const InfoChip(
                label: 'Terkunci',
                icon: Icons.lock_outline_rounded,
                tone: ChipTone.warning,
              ),
          ],
        ),
      ),
    );
  }
}

/// Kondisi perangkat dan state kanal dari `GET /api/v1/devices/{id}/state`.
class _DeviceStateSection extends StatelessWidget {
  const _DeviceStateSection({required this.view, required this.onRetry});

  final DeviceStateViewState view;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final DeviceStateSnapshot? snapshot = view.snapshot;

    return SectionCard(
      title: 'Kondisi perangkat',
      icon: Icons.sensors_outlined,
      trailing: snapshot == null
          ? null
          : InfoChip(
              label: connectionLabel(snapshot.connectionStatus),
              icon: Icons.wifi_tethering_rounded,
              tone: connectionTone(snapshot.connectionStatus),
            ),
      children: <Widget>[
        if (snapshot == null) ...<Widget>[
          if (view.isLoading)
            const Row(
              children: <Widget>[
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: ComponentTheme.space8),
                Text('Memuat kondisi perangkat...'),
              ],
            )
          else ...<Widget>[
            Text(
              view.error == null
                  ? 'Kondisi perangkat belum tersedia dari backend.'
                  : describeApiError(view.error),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: ComponentTheme.space8),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Muat Kondisi'),
            ),
          ],
        ] else ...<Widget>[
          InfoRow(
            label: 'Status koneksi',
            value: connectionLabel(snapshot.connectionStatus),
            valueColor: switch (snapshot.connectionStatus) {
              ConnectionStatus.online => ColorTokens.success,
              ConnectionStatus.offline => ColorTokens.danger,
              ConnectionStatus.unknown => ColorTokens.warning,
            },
          ),
          if (snapshot.lastUpdatedAt != null)
            InfoRow(
              label: 'Diperbarui',
              value: formatDateTime(snapshot.lastUpdatedAt!),
            ),
          if (snapshot.lastSeenAt != null)
            InfoRow(
              label: 'Terakhir terlihat',
              value: formatDateTime(snapshot.lastSeenAt!),
            ),
          if (snapshot.source != null)
            InfoRow(label: 'Sumber data', value: snapshot.source!),
          if (snapshot.error != null)
            InfoRow(
              label: 'Catatan backend',
              value: snapshot.error!,
              valueColor: ColorTokens.warning,
            ),
          if (snapshot.channels.isEmpty)
            Text(
              'Backend tidak mengirim state kanal pada respons ini.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (view.isLoading) ...<Widget>[
            const SizedBox(height: ComponentTheme.space8),
            const LinearProgressIndicator(minHeight: 2),
          ],
          if (view.error != null && !view.isLoading) ...<Widget>[
            const SizedBox(height: ComponentTheme.space8),
            Text(
              'Pembaruan kondisi gagal: ${describeApiError(view.error)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: ColorTokens.warning),
            ),
          ],
        ],
      ],
    );
  }
}

/// Tombol kontrol seluruh perangkat.
class _ControlSection extends StatelessWidget {
  const _ControlSection({
    required this.device,
    required this.blockedReason,
    required this.onTurnOn,
    required this.onTurnOff,
    required this.onCompleted,
  });

  final Device device;
  final String? blockedReason;
  final Future<void> Function() onTurnOn;
  final Future<void> Function() onTurnOff;
  final Future<void> Function() onCompleted;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SectionCard(
      title: 'Kontrol',
      icon: Icons.power_settings_new_rounded,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: FilledButton.icon(
                onPressed: blockedReason == null
                    ? () => _run(
                        context,
                        onTurnOn,
                        device.isMultiChannel
                            ? 'Semua kanal dinyalakan'
                            : 'Perangkat dinyalakan',
                      )
                    : null,
                icon: const Icon(Icons.power_settings_new, size: 18),
                label: Text(
                  device.isMultiChannel ? 'Nyalakan Semua' : 'Nyalakan',
                ),
              ),
            ),
            const SizedBox(width: ComponentTheme.space12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: blockedReason == null
                    ? () => _run(
                        context,
                        onTurnOff,
                        device.isMultiChannel
                            ? 'Semua kanal dimatikan'
                            : 'Perangkat dimatikan',
                      )
                    : null,
                icon: const Icon(Icons.power_off, size: 18),
                label: Text(
                  device.isMultiChannel ? 'Matikan Semua' : 'Matikan',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: ComponentTheme.space12),
        if (blockedReason != null)
          StatusNote(text: blockedReason!, tone: StatusNoteTone.warning)
        else
          Text(
            'Perintah dikirim ke backend. Kondisi kanal diperbarui setelah '
            'backend mengonfirmasi, bukan langsung di UI.',
            style: textTheme.bodySmall,
          ),
      ],
    );
  }

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
    String successMessage,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      await onCompleted();
      messenger.showSnackBar(SnackBar(content: Text(successMessage)));
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
}

class _ChannelControlDialog extends ConsumerWidget {
  const _ChannelControlDialog({
    required this.device,
    required this.channelIndex,
  });

  final Device device;
  final int channelIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DeviceControlState control = ref.watch(deviceControlProvider);
    final List<DeviceChannel> channels =
        device.channels ?? const <DeviceChannel>[];
    final DeviceChannel? channel = channelIndex < channels.length
        ? channels[channelIndex]
        : null;
    final bool busy =
        control.isControlling && control.pendingCommand?.deviceId == device.id;

    Future<void> run(bool value) async {
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      try {
        await ref
            .read(deviceControlProvider.notifier)
            .setChannelState(device, channelIndex, value);
        await ref.read(deviceStateProvider(device.id).notifier).refresh();
        // Dialog tidak dapat ditutup selama perintah berjalan (lihat PopScope
        // di bawah). Pemeriksaan ini menjaga agar penyelesaian perintah tidak
        // pernah mem-pop halaman detail bila dialog sudah tidak ada.
        if (!context.mounted) {
          return;
        }
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Perintah ${value ? 'ON' : 'OFF'} terkirim ke backend.',
            ),
          ),
        );
        Navigator.of(context).pop();
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

    return PopScope(
      // Barrier dan tombol back tidak boleh menutup dialog saat perintah
      // sedang dikirim, agar pop setelah await tidak mengenai halaman detail.
      canPop: !busy,
      child: AlertDialog(
        title: Text('Kontrol kanal ${channelIndex + 1}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              channel?.name ?? 'Kanal ${channelIndex + 1}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: ComponentTheme.space12),
            if (busy)
              const Row(
                children: <Widget>[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: ComponentTheme.space8),
                  Text('Mengirim...'),
                ],
              )
            else
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => run(true),
                      icon: const Icon(Icons.power_settings_new, size: 18),
                      label: const Text('ON'),
                    ),
                  ),
                  const SizedBox(width: ComponentTheme.space12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => run(false),
                      icon: const Icon(Icons.power_off, size: 18),
                      label: const Text('OFF'),
                    ),
                  ),
                ],
              ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: busy ? null : () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
