import 'package:flutter/material.dart';

import '../utils/error_message.dart';
import 'empty_state.dart';

/// Tampilan kegagalan pemuatan data dengan aksi coba lagi.
///
/// Pesan diambil dari [describeApiError] agar setiap layar memakai pemetaan
/// error yang sama.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.error,
    this.title = 'Gagal memuat data',
    this.onRetry,
    this.footnote = 'Periksa koneksi backend, lalu coba lagi.',
  });

  final Object? error;
  final String title;
  final VoidCallback? onRetry;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline_rounded,
      title: title,
      message: describeApiError(error),
      footnote: footnote,
      action: onRetry == null
          ? null
          : FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
            ),
    );
  }
}
