// Unit test ringkasan jumlah perangkat pada DeviceListState.

import 'package:flutter_test/flutter_test.dart';

import 'package:elfan_mobile/data/models/device_model.dart';
import 'package:elfan_mobile/data/providers/device_providers.dart';

Device _device(String id, {bool verificationRequired = false}) {
  return Device(
    id: id,
    name: 'Perangkat $id',
    location: 'Gedung A',
    type: 'switch',
    deviceId: 'contoh-$id',
    category: 'kg',
    enabled: true,
    verificationRequired: verificationRequired ? true : null,
  );
}

void main() {
  group('DeviceListState.supportedDevices', () {
    test('mengurangi jumlah perangkat perlu verifikasi dari total backend', () {
      final DeviceListState state = DeviceListState(
        total: 3,
        devices: <Device>[
          _device('a'),
          _device('b', verificationRequired: true),
          _device('c'),
        ],
      );

      expect(state.unsupportedCount, 1);
      expect(state.supportedDevices, 2);
    });

    test(
      'tidak negatif saat total lebih kecil dari jumlah perlu verifikasi',
      () {
        final DeviceListState state = DeviceListState(
          total: 0,
          devices: <Device>[_device('a', verificationRequired: true)],
        );

        expect(state.supportedDevices, 0);
      },
    );

    test('tidak negatif saat semua perangkat perlu verifikasi', () {
      final DeviceListState state = DeviceListState(
        total: 2,
        devices: <Device>[
          _device('a', verificationRequired: true),
          _device('b', verificationRequired: true),
        ],
      );

      expect(state.supportedDevices, 0);
    });
  });
}
