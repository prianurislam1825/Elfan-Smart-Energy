import 'package:flutter/material.dart';

import '../../core/theme/color_tokens.dart';
import '../../core/theme/component_theme.dart';

/// Empty state profesional yang dipakai bersama.
///
/// Dipakai untuk menandai modul yang belum terhubung ke backend. Tidak ada data
/// contoh/dummy yang ditampilkan seolah-olah data aktual (AI_RULES §6).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.footnote,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? footnote;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: ColorTokens.surface,
        borderRadius: BorderRadius.circular(ComponentTheme.radiusLarge),
        border: Border.all(color: ColorTokens.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: ColorTokens.background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 26, color: ColorTokens.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall,
          ),
          if (footnote != null) ...<Widget>[
            const SizedBox(height: 14),
            Text(
              footnote!,
              textAlign: TextAlign.center,
              style: textTheme.labelSmall,
            ),
          ],
          if (action != null) ...<Widget>[const SizedBox(height: 20), action!],
        ],
      ),
    );
  }
}
