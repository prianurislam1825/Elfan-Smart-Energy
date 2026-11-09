import 'package:flutter/material.dart';

import '../../../shared/widgets/feature_placeholder.dart';

/// Daftar dan live view CCTV (Phase 6).
class CctvScreen extends StatelessWidget {
  const CctvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      icon: Icons.videocam_outlined,
      title: 'CCTV',
      subtitle: 'Live view kamera',
      description:
          'Daftar kamera dan live view melalui MediaMTX WebRTC. Sesi stream '
          'dan otorisasi kamera ditentukan backend.',
      phaseLabel: 'Phase 6 · CCTV',
      capabilities: <String>[
        'Daftar kamera sesuai permission pengguna',
        'Live view WebRTC dengan indikator koneksi',
        'Multi-camera pada layar kecil',
        'Penanganan loading, error, reconnect, dan pelepasan resource',
      ],
      emptyTitle: 'Belum ada kamera terdaftar',
      emptyMessage:
          'Daftar kamera dan sesi stream memerlukan endpoint signaling serta '
          'otorisasi yang belum diaudit. Tidak ada stream contoh yang diputar.',
    );
  }
}
