import 'package:flutter/material.dart';

import '../../core/theme/component_theme.dart';

/// Kartu berjudul dengan pola konsisten untuk seluruh halaman ELFAN.
///
/// Menggantikan salinan layout `Card > Padding(20) > judul + isi` yang
/// sebelumnya ditulis ulang di beberapa layar, sehingga padding, ikon, dan
/// jarak antar elemen tetap seragam.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
    this.children = const <Widget>[],
    this.contentSpacing = ComponentTheme.space12,
  });

  final String title;
  final IconData? icon;
  final Widget? trailing;
  final List<Widget> children;
  final double contentSpacing;

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
                if (icon != null) ...<Widget>[
                  Icon(
                    icon,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: ComponentTheme.space8),
                ],
                Expanded(child: Text(title, style: textTheme.titleMedium)),
                if (trailing != null) trailing!,
              ],
            ),
            if (children.isNotEmpty) ...<Widget>[
              SizedBox(height: contentSpacing),
              ...children,
            ],
          ],
        ),
      ),
    );
  }
}
