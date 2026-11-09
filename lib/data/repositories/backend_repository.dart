import '../../core/constants/api_endpoints.dart';
import '../models/backend_health_model.dart';
import '../services/api_client.dart';

/// Repository pemeriksaan koneksi backend.
///
/// Memakai [ApiClient] terpusat (base URL dari `AppConfig`), sehingga tidak ada
/// alamat backend yang di-hardcode di sini.
class BackendRepository {
  BackendRepository({required this.apiClient});

  final ApiClient apiClient;

  /// Panggil `GET /health`.
  ///
  /// Keberhasilan request dianggap sebagai bukti backend dapat dijangkau.
  /// Kegagalan diteruskan sebagai `ApiException` agar lapisan presentasi dapat
  /// membedakan timeout, koneksi ditolak, dan error HTTP.
  Future<BackendHealth> checkHealth() async {
    final Stopwatch stopwatch = Stopwatch()..start();
    final Object? data = await apiClient.get<dynamic>(ApiEndpoints.health);
    stopwatch.stop();
    return BackendHealth.parse(
      data,
      checkedAt: DateTime.now(),
      latencyMs: stopwatch.elapsedMilliseconds,
    );
  }
}
