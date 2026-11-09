import 'package:flutter/material.dart';

import 'color_tokens.dart';
import 'text_styles.dart';

/// Radius, tinggi kontrol, dan tema komponen ELFAN.
abstract final class ComponentTheme {
  static const double radiusSmall = 10;
  static const double radiusMedium = 14;
  static const double radiusLarge = 20;
  static const double cardRadius = 16;
  static const double controlHeight = 48;

  static final AppBarTheme appBar = AppBarTheme(
    backgroundColor: ColorTokens.surface,
    foregroundColor: ColorTokens.textPrimary,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    toolbarHeight: 64,
    titleSpacing: 20,
    titleTextStyle: TextStyles.textTheme.titleMedium,
    shape: const Border(bottom: BorderSide(color: ColorTokens.border)),
  );

  static final CardThemeData card = CardThemeData(
    color: ColorTokens.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(cardRadius),
      side: const BorderSide(color: ColorTokens.border),
    ),
  );

  static final NavigationBarThemeData navigationBar = NavigationBarThemeData(
    backgroundColor: ColorTokens.surface,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.transparent,
    elevation: 0,
    height: 68,
    indicatorColor: ColorTokens.primarySoft,
    indicatorShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusSmall),
    ),
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      final bool selected = states.contains(WidgetState.selected);
      return IconThemeData(
        size: 24,
        color: selected ? ColorTokens.primary : ColorTokens.textSecondary,
      );
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      final bool selected = states.contains(WidgetState.selected);
      return TextStyles.textTheme.labelMedium?.copyWith(
        color: selected ? ColorTokens.primary : ColorTokens.textSecondary,
      );
    }),
  );

  static final FilledButtonThemeData filledButton = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, controlHeight),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: ColorTokens.primary,
      foregroundColor: Colors.white,
      disabledBackgroundColor: ColorTokens.border,
      disabledForegroundColor: ColorTokens.textSecondary,
      textStyle: TextStyles.textTheme.labelLarge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
    ),
  );

  static final OutlinedButtonThemeData outlinedButton = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(0, controlHeight),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      foregroundColor: ColorTokens.primary,
      side: const BorderSide(color: ColorTokens.border),
      textStyle: TextStyles.textTheme.labelLarge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
    ),
  );

  static final TextButtonThemeData textButton = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: ColorTokens.primary,
      textStyle: TextStyles.textTheme.labelLarge,
      minimumSize: const Size(0, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
      ),
    ),
  );

  static final InputDecorationTheme input = InputDecorationTheme(
    filled: true,
    fillColor: ColorTokens.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: TextStyles.textTheme.bodyMedium?.copyWith(
      color: ColorTokens.textSecondary,
    ),
    labelStyle: TextStyles.textTheme.bodyMedium,
    border: _inputBorder(ColorTokens.border),
    enabledBorder: _inputBorder(ColorTokens.border),
    focusedBorder: _inputBorder(ColorTokens.primary, width: 1.5),
    errorBorder: _inputBorder(ColorTokens.danger),
    focusedErrorBorder: _inputBorder(ColorTokens.danger, width: 1.5),
  );

  static const DividerThemeData divider = DividerThemeData(
    color: ColorTokens.border,
    thickness: 1,
    space: 1,
  );

  static final ChipThemeData chip = ChipThemeData(
    backgroundColor: ColorTokens.background,
    surfaceTintColor: Colors.transparent,
    side: const BorderSide(color: ColorTokens.border),
    labelStyle: TextStyles.textTheme.labelMedium?.copyWith(
      color: ColorTokens.textSecondary,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    shape: const StadiumBorder(),
    showCheckmark: false,
  );

  static final SnackBarThemeData snackBar = SnackBarThemeData(
    backgroundColor: ColorTokens.textPrimary,
    contentTextStyle: TextStyles.textTheme.bodyMedium?.copyWith(
      color: Colors.white,
    ),
    actionTextColor: ColorTokens.primarySoft,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusSmall),
    ),
  );

  static final DialogThemeData dialog = DialogThemeData(
    backgroundColor: ColorTokens.surface,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyles.textTheme.titleLarge,
    contentTextStyle: TextStyles.textTheme.bodyMedium,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusLarge),
    ),
  );

  static const ProgressIndicatorThemeData progressIndicator =
      ProgressIndicatorThemeData(
        color: ColorTokens.primary,
        linearTrackColor: ColorTokens.primarySoft,
        circularTrackColor: ColorTokens.primarySoft,
      );

  static final BottomSheetThemeData bottomSheet = BottomSheetThemeData(
    backgroundColor: ColorTokens.surface,
    surfaceTintColor: Colors.transparent,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLarge)),
    ),
  );

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
