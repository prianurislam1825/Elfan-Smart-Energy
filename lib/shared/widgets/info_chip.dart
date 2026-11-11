import 'package:flutter/material.dart';

import '../../core/theme/color_tokens.dart';
import '../../core/theme/text_styles.dart';

/// Nada warna chip status.
enum ChipTone { neutral, primary, success, warning, danger, info }

/// Chip kecil untuk status/label meta.
class InfoChip extends StatelessWidget {
  const InfoChip({
    super.key,
    required this.label,
    this.icon,
    this.tone = ChipTone.neutral,
  });

  final String label;
  final IconData? icon;
  final ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color foreground, Color background) = switch (tone) {
      ChipTone.neutral => (ColorTokens.textSecondary, ColorTokens.background),
      ChipTone.primary => (ColorTokens.primaryDark, ColorTokens.primarySoft),
      ChipTone.success => (ColorTokens.success, ColorTokens.successSoft),
      ChipTone.warning => (ColorTokens.warning, ColorTokens.warningSoft),
      ChipTone.danger => (ColorTokens.danger, ColorTokens.dangerSoft),
      ChipTone.info => (ColorTokens.info, ColorTokens.infoSoft),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
