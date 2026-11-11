import 'package:flutter/material.dart';

import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/monitoring_model.dart';
import '../../../shared/widgets/info_chip.dart';

/// Helper tampilan status perangkat yang dipakai layar daftar dan detail.
///
/// Status koneksi perangkat (`connection_status`) dan state kanal (`ON`/`OFF`)
/// selalu diperlakukan sebagai dua hal berbeda.

String connectionLabel(ConnectionStatus status) =>
    status.displayName.toUpperCase();

ChipTone connectionTone(ConnectionStatus status) {
  return switch (status) {
    ConnectionStatus.online => ChipTone.success,
    ConnectionStatus.offline => ChipTone.danger,
    ConnectionStatus.unknown => ChipTone.warning,
  };
}

/// Label state kanal. State yang tidak dikirim backend ditulis apa adanya
/// sebagai `belum tersedia`, bukan ditebak menjadi OFF.
String channelStateLabel(ChannelState? state) {
  return switch (state) {
    ChannelState.on => 'ON',
    ChannelState.off => 'OFF',
    ChannelState.unknown || null => 'belum tersedia',
  };
}

ChipTone channelTone(ChannelState? state) {
  return switch (state) {
    ChannelState.on => ChipTone.success,
    ChannelState.off => ChipTone.neutral,
    ChannelState.unknown || null => ChipTone.warning,
  };
}

IconData channelIcon(ChannelState? state) {
  return switch (state) {
    ChannelState.on => Icons.toggle_on_rounded,
    ChannelState.off => Icons.toggle_off_rounded,
    ChannelState.unknown || null => Icons.help_outline_rounded,
  };
}

Color channelIconColor(ChannelState? state) {
  return switch (state) {
    ChannelState.on => ColorTokens.success,
    ChannelState.off => ColorTokens.textSecondary,
    ChannelState.unknown || null => ColorTokens.warning,
  };
}

/// Chip kecil untuk state satu kanal.
class ChannelStateChip extends StatelessWidget {
  const ChannelStateChip({super.key, required this.name, required this.state});

  final String name;
  final ChannelState? state;

  @override
  Widget build(BuildContext context) {
    return InfoChip(
      label: '$name · ${channelStateLabel(state)}',
      icon: channelIcon(state),
      tone: channelTone(state),
    );
  }
}

/// Baris teks kecil bercorak status; dipakai untuk catatan pembatas.
class StatusNote extends StatelessWidget {
  const StatusNote({
    super.key,
    required this.text,
    this.tone = StatusNoteTone.neutral,
  });

  final String text;
  final StatusNoteTone tone;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (tone) {
      StatusNoteTone.neutral => ColorTokens.textSecondary,
      StatusNoteTone.warning => ColorTokens.warning,
      StatusNoteTone.danger => ColorTokens.danger,
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(Icons.info_outline_rounded, size: 14, color: color),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyles.textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

enum StatusNoteTone { neutral, warning, danger }
