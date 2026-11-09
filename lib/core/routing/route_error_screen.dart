import 'package:flutter/material.dart';

import '../../shared/widgets/elfan_brand.dart';
import '../../shared/widgets/empty_state.dart';
import '../theme/color_tokens.dart';
import '../utils/responsive.dart';

/// Halaman error untuk route yang tidak dikenali.
class RouteErrorScreen extends StatelessWidget {
  const RouteErrorScreen({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final double padding = Responsive.pagePadding(context);
    return Scaffold(
      appBar: const ElfanAppBar(
        title: 'Halaman tidak ditemukan',
        subtitle: 'Rute tidak tersedia',
      ),
      body: SafeArea(
        top: false,
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.fromLTRB(padding, 24, padding, 28),
            children: <Widget>[
              EmptyState(
                icon: Icons.explore_off_outlined,
                title: 'Rute tidak dikenali',
                message:
                    'Alamat "$location" tidak tersedia di aplikasi ini. '
                    'Kembali ke salah satu menu utama melalui navigasi di bawah.',
                footnote: 'ELFAN Mobile V2',
                action: FilledButton.icon(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Kembali'),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: ColorTokens.background,
    );
  }
}
