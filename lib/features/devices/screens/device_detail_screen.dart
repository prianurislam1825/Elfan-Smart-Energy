import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/device_model.dart';
import '../../../data/providers/device_providers.dart';
import '../../../data/providers/device_control_provider.dart';
import '../../../shared/widgets/elfan_brand.dart';
import '../../../shared/widgets/empty_state.dart';

/// Halaman detail perangkat.
class DeviceDetailScreen extends ConsumerWidget {
  const DeviceDetailScreen({super.key, required this.deviceId});

  final String deviceId;

  static void navigate(BuildContext context, String deviceId) {
    context.push('/devices/$deviceId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DeviceDetailState state = ref.watch(deviceDetailProvider(deviceId));
    final controlState = ref.watch(deviceControlProvider);

    if (state.isLoading) {
      return Scaffold(
        appBar: const ElfanAppBar(
          title: 'Detail Perangkat',
          subtitle: 'Memuat...',
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null && state.device == null) {
      return Scaffold(
        appBar: const ElfanAppBar(title: 'Detail Perangkat'),
        body: _ErrorView(
          error: state.error!,
          onRetry: () =>
              ref.read(deviceDetailProvider(deviceId).notifier).refresh(deviceId),
        ),
      );
    }

    final device = state.device;
    if (device == null) {
      return Scaffold(
        appBar: const ElfanAppBar(title: 'Detail Perangkat'),
        body: const EmptyState(
          icon: Icons.devices_other_outlined,
          title: 'Perangkat tidak ditemukan',
          message: 'Perangkat dengan ID tersebut tidak tersedia.',
          footnote: 'ELFAN Mobile V2',
        ),
      );
    }

    return Scaffold(
      appBar: ElfanAppBar(
        title: device.name,
        subtitle: device.location,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              ref.read(deviceDetailProvider(deviceId).notifier).refresh(deviceId);
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Muat Ulang',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              Responsive.pagePadding(context),
              20,
              Responsive.pagePadding(context),
              28,
            ),
            children: <Widget>[
              _InfoSection(
                title: 'Informasi Perangkat',
                children: <Widget>[
                  _InfoRow(label: 'Nama', value: device.name),
                  _InfoRow(label: 'Tipe', value: _capitalize(device.type)),
                  _InfoRow(label: 'Kategori', value: device.category),
                  _InfoRow(
                    label: 'Lokasi',
                    value: device.location.isEmpty
                        ? 'Belum ditentukan'
                        : device.location,
                  ),
                  _InfoRow(
                    label: 'Status',
                    value: device.enabled ? 'Aktif' : 'Nonaktif',
                  ),
                  if (device.isVerificationRequired)
                    _InfoRow(
                      label: 'Verifikasi',
                      value: 'Diperlukan',
                      valueColor: ColorTokens.danger,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (device.isMultiChannel && device.channels != null) ...<Widget>[
                _InfoSection(
                  title: 'Channel (${device.channels!.length})',
                  children: <Widget>[
                    ...device.channels!.asMap().entries.map((entry) {
                      final channel = entry.value;
                      final channelNum = entry.key + 1;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: channel.isOn
                                ? ColorTokens.successSoft
                                : ColorTokens.background,
                            child: Icon(
                              channel.isOn ? Icons.check_circle : Icons.circle,
                              color: channel.isOn
                                  ? ColorTokens.success
                                  : ColorTokens.textSecondary,
                              size: 12,
                            ),
                          ),
                          title: Text('Kanal $channelNum: ${channel.name}'),
                          subtitle: Text(
                            'DP: ${channel.switchDp} | Status: ${channel.state?.toUpperCase() ?? "--"}',
                          ),
                          trailing: channel.isOn
                              ? const Icon(
                                  Icons.toggle_on,
                                  color: ColorTokens.success,
                                )
                              : const Icon(
                                  Icons.toggle_off,
                                  color: ColorTokens.textSecondary,
                                ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => _ChannelControlDialog(
                                device: device,
                                channelIndex: channelNum - 1,
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              _InfoSection(
                title: 'Kontrol',
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FilledButton.icon(
                          onPressed:
                              controlState.isControlling ||
                                  device.isVerificationRequired
                              ? null
                              : () async {
                                  if (device.isMultiChannel) {
                                    await ref
                                        .read(deviceControlProvider.notifier)
                                        .turnAllOn(device);
                                  } else {
                                    await ref
                                        .read(deviceControlProvider.notifier)
                                        .turnOn(device);
                                  }
                                  if (context.mounted) {
                                    ref
                                        .read(
                                          deviceDetailProvider(
                                            deviceId,
                                          ).notifier,
                                        )
                                        .refresh(deviceId);
                                  }
                                },
                          icon: const Icon(Icons.power_settings_new, size: 18),
                          label: const Text('Nyalakan'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              controlState.isControlling ||
                                  device.isVerificationRequired
                              ? null
                              : () async {
                                  if (device.isMultiChannel) {
                                    await ref
                                        .read(deviceControlProvider.notifier)
                                        .turnAllOff(device);
                                  } else {
                                    await ref
                                        .read(deviceControlProvider.notifier)
                                        .turnOff(device);
                                  }
                                  if (context.mounted) {
                                    ref
                                        .read(
                                          deviceDetailProvider(
                                            deviceId,
                                          ).notifier,
                                        )
                                        .refresh(deviceId);
                                  }
                                },
                          icon: const Icon(Icons.power_off, size: 18),
                          label: const Text('Matikan'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    device.isVerificationRequired
                        ? 'Perangkat ini memerlukan verifikasi sebelum dikontrol.'
                        : 'Perintah dikirim melalui backend.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: ColorTokens.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: valueColor != null
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
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
    final controlState = ref.watch(deviceControlProvider);

    return AlertDialog(
      title: Text('Kontrol Kanal ${channelIndex + 1}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (controlState.pendingCommand?.deviceId == device.id &&
              controlState.pendingCommand?.channelIndex == channelIndex)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(strokeWidth: 2),
                SizedBox(width: 8),
                Text('Mengirim...'),
              ],
            )
          else ...<Widget>[
            Text(
              device.channels?[channelIndex].name ??
                  'Kanal ${channelIndex + 1}',
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: controlState.isControlling
                        ? null
                        : () async {
                            await ref
                                .read(deviceControlProvider.notifier)
                                .setChannelState(device, channelIndex, true);
                            if (context.mounted) Navigator.of(context).pop();
                          },
                    icon: const Icon(Icons.power_settings_new, size: 18),
                    label: const Text('ON'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controlState.isControlling
                        ? null
                        : () async {
                            await ref
                                .read(deviceControlProvider.notifier)
                                .setChannelState(device, channelIndex, false);
                            if (context.mounted) Navigator.of(context).pop();
                          },
                    icon: const Icon(Icons.power_off, size: 18),
                    label: const Text('OFF'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: ColorTokens.danger,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat detail',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _getMessage(error),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  String _getMessage(Object e) {
    if (e is String) return e;
    if (e.toString().contains('configuration')) {
      return 'Konfigurasi API belum siap.';
    }
    if (e.toString().contains('timeout') ||
        e.toString().contains('Tidak dapat terhubung')) {
      return 'Tidak dapat terhubung ke server.';
    }
    return 'Terjadi kesalahan: ${e.toString().split('\n').first}';
  }
}
