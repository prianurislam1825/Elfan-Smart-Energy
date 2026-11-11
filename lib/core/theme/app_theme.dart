import 'package:flutter/material.dart';

import 'color_tokens.dart';
import 'component_theme.dart';
import 'text_styles.dart';

/// Tema aplikasi ELFAN (Material 3, light only untuk Phase 1).
abstract final class AppTheme {
  static ThemeData get light {
    final ColorScheme seed = ColorScheme.fromSeed(
      seedColor: ColorTokens.primary,
      brightness: Brightness.light,
    );

    final ColorScheme scheme = seed.copyWith(
      primary: ColorTokens.primary,
      onPrimary: Colors.white,
      primaryContainer: ColorTokens.primarySoft,
      onPrimaryContainer: ColorTokens.primaryDark,
      secondary: ColorTokens.primaryDark,
      onSecondary: Colors.white,
      secondaryContainer: ColorTokens.primarySoft,
      onSecondaryContainer: ColorTokens.primaryDark,
      tertiary: ColorTokens.info,
      onTertiary: Colors.white,
      error: ColorTokens.danger,
      onError: Colors.white,
      surface: ColorTokens.surface,
      onSurface: ColorTokens.textPrimary,
      onSurfaceVariant: ColorTokens.textSecondary,
      surfaceContainerLowest: ColorTokens.surface,
      surfaceContainerLow: ColorTokens.surface,
      surfaceContainer: ColorTokens.surface,
      surfaceContainerHigh: ColorTokens.surface,
      surfaceContainerHighest: ColorTokens.background,
      outline: ColorTokens.border,
      outlineVariant: ColorTokens.border,
      surfaceTint: Colors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      primaryColor: ColorTokens.primary,
      scaffoldBackgroundColor: ColorTokens.background,
      canvasColor: ColorTokens.surface,
      dividerColor: ColorTokens.border,
      textTheme: TextStyles.textTheme,
      appBarTheme: ComponentTheme.appBar,
      cardTheme: ComponentTheme.card,
      navigationBarTheme: ComponentTheme.navigationBar,
      navigationRailTheme: ComponentTheme.navigationRail,
      filledButtonTheme: ComponentTheme.filledButton,
      outlinedButtonTheme: ComponentTheme.outlinedButton,
      textButtonTheme: ComponentTheme.textButton,
      inputDecorationTheme: ComponentTheme.input,
      dividerTheme: ComponentTheme.divider,
      chipTheme: ComponentTheme.chip,
      snackBarTheme: ComponentTheme.snackBar,
      dialogTheme: ComponentTheme.dialog,
      progressIndicatorTheme: ComponentTheme.progressIndicator,
      bottomSheetTheme: ComponentTheme.bottomSheet,
      visualDensity: VisualDensity.standard,
    );
  }
}
