import 'package:flutter/material.dart';

import '../../core/theme/color_tokens.dart';
import '../../core/theme/component_theme.dart';
import '../../core/theme/text_styles.dart';

/// Tanda merek ELFAN tanpa berkas gambar.
///
/// Folder `assets/` masih kosong dan belum dideklarasikan di `pubspec.yaml`,
/// sehingga identitas visual dibuat dari token warna dan tipografi.
class ElfanBrandMark extends StatelessWidget {
  const ElfanBrandMark({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Logo ELFAN',
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[ColorTokens.primary, ColorTokens.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.3),
          ),
          child: Text(
            'E',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.52,
              fontWeight: FontWeight.w800,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

/// Wordmark "ELFAN" untuk header/branding.
class ElfanWordmark extends StatelessWidget {
  const ElfanWordmark({super.key, this.color = ColorTokens.textPrimary});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'ELFAN',
      style: TextStyles.textTheme.titleLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.4,
      ),
    );
  }
}

/// App bar konsisten untuk seluruh halaman fitur.
class ElfanAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ElfanAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBrand = true,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBrand;

  @override
  Size get preferredSize {
    return Size.fromHeight(
      ComponentTheme.appBar.toolbarHeight ?? kToolbarHeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return AppBar(
      titleSpacing: showBrand ? 20 : null,
      title: Row(
        children: <Widget>[
          if (showBrand) ...<Widget>[
            const ElfanBrandMark(size: 30),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }
}
