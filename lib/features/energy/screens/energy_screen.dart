import 'package:flutter/material.dart';

import '../../../shared/widgets/feature_placeholder.dart';

/// Pemantauan energi (Phase 7).
class EnergyScreen extends StatelessWidget {
  const EnergyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      icon: Icons.bolt_outlined,
      title: 'Energi',
      subtitle: 'Pemantauan konsumsi',
      description:
          'Data daya, tegangan, arus, dan energi ditampilkan hanya jika '
          'sumber telemetry tersedia melalui API backend.',
      phaseLabel: 'Phase 7 · Energy',
      capabilities: <String>[
        'Nilai daya, tegangan, arus, dan energi dengan satuan jelas',
        'Grafik dan histori sesuai periode yang didukung API',
        'Timestamp dan kualitas data (stale/partial)',
        'Nilai kosong ditampilkan sebagai "tidak tersedia", bukan nol',
      ],
      emptyTitle: 'Belum ada data energi',
      emptyMessage:
          'Sumber sensor, satuan, dan interval pengambilan data belum '
          'diinventarisasi dari backend, sehingga tidak ada grafik contoh.',
    );
  }
}
