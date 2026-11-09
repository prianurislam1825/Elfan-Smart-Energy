import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config_provider.dart';
import 'api_client.dart';

/// Instance [ApiClient] tunggal untuk aplikasi.
///
/// Dio ditutup otomatis ketika provider di-dispose. Belum ada interceptor
/// autentikasi karena mekanisme auth ditetapkan pada Phase 2.
final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) {
  final ApiClient client = ApiClient(config: ref.watch(appConfigProvider));
  ref.onDispose(client.close);
  return client;
});
