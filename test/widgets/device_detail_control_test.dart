// Widget test dialog kontrol kanal pada halaman detail perangkat.
//
// Memakai repository palsu dengan perintah yang ditahan (Completer) agar
// kondisi "perintah sedang dikirim" dapat diuji tanpa jaringan.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elfan_mobile/core/config/app_config.dart';
import 'package:elfan_mobile/core/theme/app_theme.dart';
import 'package:elfan_mobile/data/models/device_model.dart';
import 'package:elfan_mobile/data/models/device_state_model.dart';
import 'package:elfan_mobile/data/models/monitoring_model.dart';
import 'package:elfan_mobile/data/providers/device_providers.dart';
import 'package:elfan_mobile/data/repositories/device_repository.dart';
import 'package:elfan_mobile/data/services/api_client.dart';
import 'package:elfan_mobile/features/devices/screens/device_detail_screen.dart';

class _FakeDeviceRepository implements DeviceRepository {
  _FakeDeviceRepository({required this.device, required this.commandCompleter});

  final Device device;
  final Completer<Map<String, dynamic>> commandCompleter;

  @override
  final ApiClient apiClient = ApiClient(
    config: const AppConfig(apiBaseUrl: ''),
  );

  @override
  Future<DeviceListResponse> getDevices() async =>
      DeviceListResponse(total: 1, devices: <Device>[device]);

  @override
  Future<Device?> getDevice(String logicalId) async => device;

  @override
  Future<Device?> getDeviceStatus(String logicalId) async => null;

  @override
  Future<DeviceStateSnapshot?> getDeviceState(String logicalId) async {
    return DeviceStateSnapshot(
      logicalId: device.id,
      name: device.name,
      location: device.location,
      connectionStatus: ConnectionStatus.online,
      channels: const <MonitoringChannelResult>[
        MonitoringChannelResult(
          id: 'c1',
          name: 'Lampu Utama',
          switchDp: 'switch_1',
          state: ChannelState.off,
          status: ChannelStatus.online,
        ),
      ],
    );
  }

  @override
  Future<Map<String, dynamic>> sendCommand(
    String logicalId,
    Map<String, dynamic> command,
  ) {
    return commandCompleter.future;
  }

  @override
  Future<MonitoringStatusResponse> getMonitoringStatus() async {
    throw UnimplementedError('Monitoring tidak dipakai di test ini.');
  }

  @override
  Future<MonitoringStatusResponse> checkMonitoring() async {
    throw UnimplementedError('Monitoring tidak dipakai di test ini.');
  }
}

final Device _device = Device(
  id: 'logical-switch',
  name: 'Sakelar Ruang Rapat',
  location: 'Gedung Mekah Lt 2',
  type: 'switch',
  deviceId: 'contoh',
  category: 'kg',
  enabled: true,
  channels: const <DeviceChannel>[
    DeviceChannel(id: 'c1', name: 'Lampu Utama', switchDp: 'switch_1'),
  ],
);

Widget _buildApp(DeviceRepository repository) {
  return ProviderScope(
    overrides: [deviceRepositoryProvider.overrideWith((Ref ref) => repository)],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const DeviceDetailScreen(deviceId: 'logical-switch'),
    ),
  );
}

Future<void> _openChannelDialog(WidgetTester tester) async {
  await tester.ensureVisible(find.text('1. Lampu Utama'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('1. Lampu Utama'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'dialog tidak tertutup lewat barrier selama perintah dan tidak mem-pop detail',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final Completer<Map<String, dynamic>> completer =
          Completer<Map<String, dynamic>>();
      await tester.pumpWidget(
        _buildApp(
          _FakeDeviceRepository(device: _device, commandCompleter: completer),
        ),
      );
      await tester.pumpAndSettle();

      await _openChannelDialog(tester);
      expect(find.text('Kontrol kanal 1'), findsOneWidget);

      await tester.tap(find.text('ON'));
      await tester.pump();
      expect(find.text('Mengirim...'), findsOneWidget);

      // Tap di luar dialog (barrier) harus diabaikan selama perintah berjalan.
      await tester.tapAt(const Offset(8, 8));
      await tester.pump();
      expect(find.text('Kontrol kanal 1'), findsOneWidget);

      completer.complete(<String, dynamic>{'success': true});
      await tester.pumpAndSettle();

      expect(find.text('Kontrol kanal 1'), findsNothing);
      // Halaman detail tetap terbuka setelah perintah selesai.
      expect(find.text('Informasi perangkat'), findsOneWidget);
      expect(
        find.textContaining('Perintah ON terkirim ke backend.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('dialog tetap dapat ditutup lewat barrier saat tidak mengirim', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _buildApp(
        _FakeDeviceRepository(
          device: _device,
          commandCompleter: Completer<Map<String, dynamic>>(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _openChannelDialog(tester);
    expect(find.text('Kontrol kanal 1'), findsOneWidget);

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    expect(find.text('Kontrol kanal 1'), findsNothing);
    expect(find.text('Informasi perangkat'), findsOneWidget);
  });
}
