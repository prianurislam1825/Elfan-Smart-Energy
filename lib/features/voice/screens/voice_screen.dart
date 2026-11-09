import 'package:flutter/material.dart';

import '../../../shared/widgets/feature_placeholder.dart';

/// Push-to-Talk Voice Assistant (Phase 5).
class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      icon: Icons.mic_none_rounded,
      title: 'Voice',
      subtitle: 'Push-to-Talk assistant',
      description:
          'Perintah suara diproses backend: audio dikirim ke Voice API, lalu '
          'STT/intent dan command engine menentukan respons.',
      phaseLabel: 'Phase 5 · Voice PTT',
      capabilities: <String>[
        'Tombol PTT dengan indikator rekam dan durasi',
        'Stop dan cancel sebelum audio dikirim',
        'Unggah audio ke kontrak Voice API yang terverifikasi',
        'Tampilan transkrip dan respons teks/TTS bila tersedia',
      ],
      emptyTitle: 'Voice assistant belum aktif',
      emptyMessage:
          'Perekaman dan pengiriman audio memerlukan kontrak Voice API serta '
          'izin mikrofon Android. Keduanya belum ditetapkan pada Phase 1.',
    );
  }
}
