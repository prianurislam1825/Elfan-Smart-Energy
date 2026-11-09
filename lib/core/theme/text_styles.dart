import 'package:flutter/material.dart';

import 'color_tokens.dart';

/// Skala tipografi ELFAN.
///
/// Tidak ada font kustom karena folder `assets/` belum berisi font dan
/// mendeklarasikan font tanpa berkas akan menggagalkan build. Skala ini memakai
/// font default platform dengan bobot dan tinggi baris yang konsisten.
abstract final class TextStyles {
  static const TextTheme textTheme = TextTheme(
    displaySmall: TextStyle(
      fontSize: 30,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
      color: ColorTokens.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 26,
      height: 1.25,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      color: ColorTokens.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontSize: 22,
      height: 1.3,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: ColorTokens.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      height: 1.3,
      fontWeight: FontWeight.w600,
      color: ColorTokens.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      height: 1.35,
      fontWeight: FontWeight.w600,
      color: ColorTokens.textPrimary,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      height: 1.35,
      fontWeight: FontWeight.w600,
      color: ColorTokens.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.5,
      color: ColorTokens.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.5,
      color: ColorTokens.textPrimary,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      height: 1.45,
      color: ColorTokens.textSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      height: 1.3,
      fontWeight: FontWeight.w600,
      color: ColorTokens.textPrimary,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      height: 1.3,
      fontWeight: FontWeight.w600,
      color: ColorTokens.textPrimary,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      height: 1.3,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: ColorTokens.textSecondary,
    ),
  );
}
