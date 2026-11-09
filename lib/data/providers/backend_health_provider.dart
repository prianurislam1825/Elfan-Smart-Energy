import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/backend_health_model.dart';
import '../repositories/backend_repository.dart';
import 'api_client_provider.dart';

/// Provider repository pemeriksaan backend.
final backendRepositoryProvider = Provider<BackendRepository>((ref) {
  return BackendRepository(apiClient: ref.watch(apiClientProvider));
});

/// Status koneksi backend.
///
/// `unknown` berarti belum pernah ada pemeriksaan aktual, sehingga UI tidak
/// boleh menampilkan status "online" hanya berdasarkan konfigurasi base URL.
enum BackendConnectionStatus { unknown, checking, connected, unreachable }

extension BackendConnectionStatusLabel on BackendConnectionStatus {
  String get displayName {
    return switch (this) {
      BackendConnectionStatus.unknown => 'Belum diperiksa',
      BackendConnectionStatus.checking => 'Memeriksa...',
      BackendConnectionStatus.connected => 'Terhubung',
      BackendConnectionStatus.unreachable => 'Tidak terhubung',
    };
  }
}

/// State hasil pemeriksaan koneksi backend.
@immutable
class BackendConnectionState {
  const BackendConnectionState({
    this.status = BackendConnectionStatus.unknown,
    this.health,
    this.error,
    this.lastCheckedAt,
  });

  final BackendConnectionStatus status;
  final BackendHealth? health;
  final Object? error;
  final DateTime? lastCheckedAt;

  bool get isConnected => status == BackendConnectionStatus.connected;
  bool get isChecking => status == BackendConnectionStatus.checking;
  bool get hasBeenChecked => lastCheckedAt != null;

  BackendConnectionState copyWith({
    BackendConnectionStatus? status,
    BackendHealth? health,
    Object? error,
    DateTime? lastCheckedAt,
    bool clearError = false,
  }) {
    return BackendConnectionState(
      status: status ?? this.status,
      health: health ?? this.health,
      error: clearError ? null : (error ?? this.error),
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
    );
  }
}

/// Notifier pemeriksaan koneksi backend (`GET /health`).
class BackendHealthNotifier extends Notifier<BackendConnectionState> {
  @override
  BackendConnectionState build() {
    // Pemeriksaan pertama dijalankan setelah build agar state tidak berubah
    // di dalam build itu sendiri. Hasilnya tetap pemeriksaan HTTP aktual.
    Future<void>.microtask(check);
    return const BackendConnectionState();
  }

  /// Periksa koneksi backend sekarang.
  Future<void> check() async {
    if (state.isChecking) return;

    state = state.copyWith(
      status: BackendConnectionStatus.checking,
      clearError: true,
    );

    try {
      final BackendHealth health = await ref
          .read(backendRepositoryProvider)
          .checkHealth();
      state = BackendConnectionState(
        status: BackendConnectionStatus.connected,
        health: health,
        lastCheckedAt: health.checkedAt,
      );
    } catch (error) {
      state = BackendConnectionState(
        status: BackendConnectionStatus.unreachable,
        health: null,
        error: error,
        lastCheckedAt: DateTime.now(),
      );
    }
  }
}

/// Provider state koneksi backend.
final backendHealthProvider =
    NotifierProvider<BackendHealthNotifier, BackendConnectionState>(
      BackendHealthNotifier.new,
    );
