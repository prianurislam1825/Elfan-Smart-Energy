import 'package:flutter/material.dart';

/// Aturan layout responsif ELFAN.
///
/// Aplikasi mobile-first: navigation bar bawah pada layar sempit, navigation
/// rail pada layar lebar (tablet/foldable) agar konten tidak melebar berlebihan.
abstract final class Responsive {
  /// Ambang untuk beralih dari bottom navigation ke navigation rail.
  static const double railBreakpoint = 900;

  /// Ambang untuk layout sangat sempit (mis. ponsel kecil).
  static const double compactBreakpoint = 600;

  /// Lebar maksimum kolom konten agar tetap nyaman dibaca di tablet.
  static const double contentMaxWidth = 880;

  static bool useNavigationRail(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= railBreakpoint;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compactBreakpoint;

  /// Padding horizontal halaman berdasarkan lebar layar.
  static double pagePadding(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) {
      return 40;
    }
    if (width >= 700) {
      return 28;
    }
    return 20;
  }
}

/// Membatasi lebar konten dan menempatkannya di tengah pada layar lebar.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = Responsive.contentMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
