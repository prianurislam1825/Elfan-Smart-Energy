import 'package:flutter/material.dart';

import '../../core/theme/color_tokens.dart';
import '../../core/theme/component_theme.dart';

/// Baris label–nilai untuk detail perangkat dan pengaturan.
///
/// Label memakai lebar tetap agar nilai sejajar antar baris; pada layar sangat
/// sempit label menyusut sehingga tidak overflow.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.labelWidth = 128,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: ComponentTheme.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: ColorTokens.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: ComponentTheme.space8),
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
