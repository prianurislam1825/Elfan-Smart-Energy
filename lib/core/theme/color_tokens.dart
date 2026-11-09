import 'package:flutter/material.dart';

/// Token warna ELFAN.
///
/// Lima token pertama diambil langsung dari `docs/05_UI_UX_GUIDELINES.md`.
/// Token semantik tambahan hanya turunan dari palet yang sama.
abstract final class ColorTokens {
  // Token baseline dokumentasi.
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF172033);
  static const Color textSecondary = Color(0xFF7B8494);

  // Turunan palet untuk kebutuhan komponen.
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primarySoft = Color(0xFFEFF4FF);
  static const Color border = Color(0xFFE4E8EF);

  // Warna status semantik.
  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFE9F7EF);
  static const Color warning = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFFDF3E3);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSoft = Color(0xFFFDECEC);
  static const Color info = Color(0xFF0284C7);
  static const Color infoSoft = Color(0xFFE8F4FB);
}
