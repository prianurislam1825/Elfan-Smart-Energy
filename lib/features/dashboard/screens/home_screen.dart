import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/config/app_config_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/color_tokens.dart';
import '../../../core/theme/component_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/elfan_brand.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/info_chip.dart';

/// Halaman awal ELFAN.
///
/// Phase 1 hanya menampilkan identitas aplikasi, status konfigurasi API, dan
/// empty state dashboard. Data fasilitas baru diisi pada Phase 2–3 setelah
/// kontrak API diverifikasi.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppConfig config = ref.watch(appConfigProvider);
    final double padding = Responsive.pagePadding(context);

    return Scaffold(
      appBar: const ElfanAppBar(title: 'Home', subtitle: 'Ringkasan fasilitas'),
      body: SafeArea(
        top: false,
        child: ResponsiveContent(
          child: ListView(
            padding: EdgeInsets.fromLTRB(padding, 20, padding, 28),
            children: <Widget>[
              const _WelcomeCard(),
              const SizedBox(height: 16),
              _IntegrationCard(config: config),
              const SizedBox(height: 16),
              const EmptyState(
                icon: Icons.space_dashboard_outlined,
                title: 'Dashboard belum terhubung',
                message:
                    'Ringkasan perangkat, status online, lokasi, dan '
                    'monitoring akan tampil setelah kontrak API diverifikasi '
                    'dan autentikasi tersedia (Phase 2–3).',
                footnote: 'Tidak ada data contoh yang ditampilkan.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[ColorTokens.primary, ColorTokens.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ComponentTheme.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const ElfanWordmark(color: Colors.white),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  AppConstants.foundationPhaseLabel,
                  style: textTheme.labelSmall?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            AppConstants.tagline,
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppConstants.description,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              InfoChip(
                label: 'Konteks aktif: belum ditentukan',
                icon: Icons.business_outlined,
                tone: ChipTone.primary,
              ),
              InfoChip(
                label: 'Sesi: belum ada',
                icon: Icons.lock_outline_rounded,
                tone: ChipTone.neutral,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IntegrationCard extends StatelessWidget {
  const _IntegrationCard({required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool configured = config.isApiConfigured;
    final String? host = config.apiHost;
    final String? problem = config.apiBaseUrlValidationError;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.dns_outlined,
                  size: 20,
                  color: ColorTokens.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Integrasi backend',
                    style: textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            InfoChip(
              label: configured
                  ? 'Base URL terkonfigurasi'
                  : 'Belum dikonfigurasi',
              icon: configured
                  ? Icons.check_circle_outline_rounded
                  : Icons.error_outline_rounded,
              tone: configured ? ChipTone.success : ChipTone.warning,
            ),
            const SizedBox(height: 12),
            if (configured && host != null) ...<Widget>[
              Text('Host API', style: textTheme.labelSmall),
              const SizedBox(height: 2),
              Text(host, style: textTheme.bodyMedium),
              const SizedBox(height: 8),
            ] else ...<Widget>[
              Text(
                problem ?? 'Konfigurasi API tidak valid.',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Tetapkan saat menjalankan aplikasi, misalnya '
                '--dart-define=${AppConfig.apiBaseUrlDefine}=https://host-api',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'Phase 1 belum memanggil endpoint apa pun. Daftar endpoint '
              'terverifikasi belum tersedia dari backend.',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
