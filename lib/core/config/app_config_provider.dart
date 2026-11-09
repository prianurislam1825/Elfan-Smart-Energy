import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_config.dart';

/// Konfigurasi aplikasi dari `--dart-define` (bukan dari UI).
final Provider<AppConfig> appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});
