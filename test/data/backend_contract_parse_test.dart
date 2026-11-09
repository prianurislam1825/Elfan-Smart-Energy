// Tes parsing kontrak backend yang terverifikasi dari respons nyata.
// Payload memakai nilai contoh, bukan data perangkat asli.

import 'package:flutter_test/flutter_test.dart';

import 'package:elfan_mobile/data/models/backend_health_model.dart';
import 'package:elfan_mobile/data/models/device_state_model.dart';
import 'package:elfan_mobile/data/models/monitoring_model.dart';

void main() {
  group('BackendHealth.parse', () {
    test('membaca status, application, dan environment dari /health', () {
      final BackendHealth health = BackendHealth.parse(
        <String, dynamic>{
          'status': 'healthy',
          'application': 'elfan-cv-engine',
          'environment': 'development',
        },
        checkedAt: DateTime(2026, 11, 9, 10, 30),
        latencyMs: 42,
      );

      expect(health.status, 'healthy');
      expect(health.application, 'elfan-cv-engine');
      expect(health.environment, 'development');
      expect(health.latencyMs, 42);
    });

    test('tidak mengarang nilai saat body bukan objek JSON', () {
      final BackendHealth health = BackendHealth.parse(
        'ok',
        checkedAt: DateTime(2026, 11, 9),
        latencyMs: 5,
      );

      expect(health.status, isNull);
      expect(health.application, isNull);
      expect(health.environment, isNull);
      expect(health.latencyMs, 5);
    });
  });

  group('DeviceStateSnapshot.tryParse', () {
    test('membaca status koneksi, kanal, dan waktu dari /state', () {
      final DeviceStateSnapshot? snapshot = DeviceStateSnapshot.tryParse(
        <String, dynamic>{
          'logical_id': 'contoh-perangkat',
          'name': 'Lampu Kelas',
          'location': 'Gedung A Lt 1',
          'connection_status': 'online',
          'last_seen_at': '2026-11-09T10:30:00',
          'last_updated_at': '2026-11-09T10:31:00',
          'source': 'tuya',
          'error': null,
          'channels': <dynamic>[
            <String, dynamic>{
              'id': 'ch-1',
              'name': 'Lampu 1',
              'switch_dp': 'switch_1',
              'state': 'on',
              'status': 'success',
            },
            <String, dynamic>{
              'id': 'ch-2',
              'name': 'Lampu 2',
              'switch_dp': 'switch_2',
              'state': 'off',
              'status': 'success',
            },
          ],
        },
      );

      expect(snapshot, isNotNull);
      expect(snapshot!.connectionStatus, ConnectionStatus.online);
      expect(snapshot.location, 'Gedung A Lt 1');
      expect(snapshot.source, 'tuya');
      expect(snapshot.channels, hasLength(2));
      expect(snapshot.channels.first.state, ChannelState.on);
      expect(snapshot.channels.last.state, ChannelState.off);
      expect(snapshot.lastUpdatedAt, DateTime(2026, 11, 9, 10, 31));
    });

    test('menandai kondisi kanal yang tidak dikirim sebagai unknown', () {
      final DeviceStateSnapshot? snapshot = DeviceStateSnapshot.tryParse(
        <String, dynamic>{
          'logical_id': 'contoh-perangkat',
          'connection_status': 'tidak-dikenal',
          'channels': <dynamic>[
            <String, dynamic>{
              'id': 'ch-1',
              'name': 'Lampu 1',
              'switch_dp': 'switch_1',
              'state': 'tidak-dikenal',
              'status': 'unknown',
            },
          ],
        },
      );

      expect(snapshot, isNotNull);
      expect(snapshot!.connectionStatus, ConnectionStatus.unknown);
      expect(snapshot.channels.single.state, ChannelState.unknown);
      expect(snapshot.lastUpdatedAt, isNull);
    });

    test('mengembalikan null tanpa logical_id', () {
      expect(
        DeviceStateSnapshot.tryParse(<String, dynamic>{'name': 'Tanpa ID'}),
        isNull,
      );
    });
  });
}
