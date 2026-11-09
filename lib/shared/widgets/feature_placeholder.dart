import 'package:flutter/material.dart';

import '../../core/theme/color_tokens.dart';
import '../../core/theme/component_theme.dart';
import '../../core/utils/responsive.dart';
import 'elfan_brand.dart';
import 'empty_state.dart';
import 'info_chip.dart';

/// Kerangka halaman modul yang belum diimplementasikan.
///
/// Menampilkan judul, deskripsi fungsi modul, daftar kapabilitas yang
/// direncanakan (diambil dari dokumentasi), dan empty state. Tidak ada data
/// perangkat/kamera/energi palsu.
class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.phaseLabel,
    this.capabilities = const <String>[],
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final String phaseLabel;
  final List<String> capabilities;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final double padding = Responsive.pagePadding(context);
    return Scaffold(
      appBar: ElfanAppBar(title: title, subtitle: subtitle),
      body: SafeArea(
        top: false,
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.fromLTRB(padding, 20, padding, 28),
            children: <Widget>[
              _ModuleHeader(
                icon: icon,
                title: title,
                description: description,
                phaseLabel: phaseLabel,
              ),
              if (capabilities.isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                _CapabilityCard(items: capabilities),
              ],
              const SizedBox(height: 20),
              EmptyState(
                icon: icon,
                title: emptyTitle,
                message: emptyMessage,
                footnote: 'Tidak ada data contoh yang ditampilkan.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleHeader extends StatelessWidget {
  const _ModuleHeader({
    required this.icon,
    required this.title,
    required this.description,
    required this.phaseLabel,
  });

  final IconData icon;
  final String title;
  final String description;
  final String phaseLabel;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ColorTokens.primarySoft,
                    borderRadius: BorderRadius.circular(
                      ComponentTheme.radiusMedium,
                    ),
                  ),
                  child: Icon(icon, size: 24, color: ColorTokens.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(description, style: textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                InfoChip(
                  label: phaseLabel,
                  icon: Icons.flag_outlined,
                  tone: ChipTone.primary,
                ),
                const InfoChip(
                  label: 'Belum terhubung',
                  icon: Icons.link_off_rounded,
                  tone: ChipTone.warning,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CapabilityCard extends StatelessWidget {
  const _CapabilityCard({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Rencana modul', style: textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'Belum diimplementasikan pada Phase 1.',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            for (final String item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
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
                    const SizedBox(width: 10),
                    Expanded(child: Text(item, style: textTheme.bodyMedium)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
