// Widget test layar Perangkat dengan repository palsu (tanpa jaringan).
//
// Data di bawah adalah contoh sintetis untuk menguji layout dan state, bukan
// inventaris perangkat sebenarnya.

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
import 'package:elfan_mobile/features/devices/screens/devices_screen.dart';

class _FakeDeviceRepository implements DeviceRepository {
  _FakeDeviceRepository({required this.devices, required this.monitoring});

  final DeviceListResponse devices;
  final MonitoringStatusResponse monitoring;

  @override
  final ApiClient apiClient = ApiClient(
    config: const AppConfig(apiBaseUrl: ''),
  );

  @override
  Future<DeviceListResponse> getDevices() async => devices;

  @override
  Future<Device?> getDevice(String logicalId) async => devices.devices
      .where((Device device) => device.id == logicalId)
      .firstOrNull;

  @override
  Future<Device?> getDeviceStatus(String logicalId) async => null;

  @override
  Future<DeviceStateSnapshot?> getDeviceState(String logicalId) async => null;

  @override
  Future<Map<String, dynamic>> sendCommand(
    String logicalId,
    Map<String, dynamic> command,
  ) async {
    throw UnimplementedError('Kontrol tidak dikirim pada widget test.');
  }

  @override
  Future<MonitoringStatusResponse> getMonitoringStatus() async => monitoring;

  @override
  Future<MonitoringStatusResponse> checkMonitoring() async => monitoring;
}

const DeviceChannel _channel1 = DeviceChannel(
  id: 'ch-1',
  name: 'Lampu 1',
  switchDp: 'switch_1',
);
const DeviceChannel _channel2 = DeviceChannel(
  id: 'ch-2',
  name: 'Lampu 2',
  switchDp: 'switch_2',
);

final Device _switchDevice = Device(
  id: 'logical-switch',
  name: 'Lampu Kelas',
  location: 'Gedung A Lt 2',
  type: 'switch',
  deviceId: 'contoh',
  category: 'kg',
  enabled: true,
  channels: const <DeviceChannel>[_channel1, _channel2],
);

final Device _unverifiedDevice = Device(
  id: 'logical-unverified',
  name: 'Perangkat Perlu Verifikasi',
  location: 'Gedung A Lt 2',
  type: 'ir_device',
  deviceId: 'contoh-2',
  category: 'qt',
  enabled: true,
  verificationRequired: true,
  channels: const <DeviceChannel>[_channel1],
);

final MonitoringStatusResponse _monitoring = MonitoringStatusResponse(
  success: true,
  data: MonitoringStatus(
    running: true,
    intervalSeconds: 60,
    lastRunAt: DateTime(2026, 11, 10, 10),
    lastResult: MonitoringResult(
      checkedAt: DateTime(2026, 11, 10, 10),
      totalDevices: 2,
      monitoredDevices: 1,
      online: 1,
      offline: 0,
      unknown: 1,
      unsupportedDevices: 1,
      results: <MonitoringDeviceResult>[
        MonitoringDeviceResult(
          logicalId: 'logical-switch',
          name: 'Lampu Kelas',
          type: 'switch',
          connectionStatus: ConnectionStatus.online,
          success: true,
          channels: const <MonitoringChannelResult>[
            MonitoringChannelResult(
              id: 'ch-1',
              name: 'Lampu 1',
              switchDp: 'switch_1',
              state: ChannelState.on,
              status: ChannelStatus.online,
            ),
            MonitoringChannelResult(
              id: 'ch-2',
              name: 'Lampu 2',
              switchDp: 'switch_2',
              state: ChannelState.off,
              status: ChannelStatus.online,
            ),
          ],
        ),
      ],
    ),
  ),
);

Widget _buildApp(DeviceRepository repository) {
  return ProviderScope(
    overrides: [deviceRepositoryProvider.overrideWith((Ref ref) => repository)],
    child: MaterialApp(theme: AppTheme.light, home: const DevicesScreen()),
  );
}

void main() {
  testWidgets('menampilkan perangkat backend tanpa overflow di layar sempit', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _buildApp(
        _FakeDeviceRepository(
          devices: DeviceListResponse(
            total: 2,
            devices: <Device>[_switchDevice, _unverifiedDevice],
          ),
          monitoring: _monitoring,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daftar perangkat'), findsOneWidget);
    expect(find.text('2 perangkat'), findsOneWidget);
    expect(find.text('Lampu Kelas'), findsOneWidget);
    // Indikator kanal dari hasil monitoring.
    expect(find.text('Lampu 1 · ON'), findsOneWidget);
    expect(find.text('Lampu 2 · OFF'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('membuka dialog kontrol untuk perangkat yang dapat dikontrol', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        _FakeDeviceRepository(
          devices: DeviceListResponse(
            total: 1,
            devices: <Device>[_switchDevice],
          ),
          monitoring: _monitoring,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Kontrol'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kontrol'));
    await tester.pumpAndSettle();

    expect(find.text('Kontrol perangkat'), findsOneWidget);
    expect(find.text('Semua ON'), findsOneWidget);
    expect(find.text('Semua OFF'), findsOneWidget);
    expect(find.textContaining('Mengirim perintah'), findsNothing);
  });

  testWidgets('menonaktifkan kontrol untuk perangkat perlu verifikasi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        _FakeDeviceRepository(
          devices: DeviceListResponse(
            total: 1,
            devices: <Device>[_unverifiedDevice],
          ),
          monitoring: _monitoring,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Perlu verifikasi'), findsOneWidget);
    expect(find.text('Perlu verifikasi sebelum dikontrol.'), findsOneWidget);

    // Tombol kontrol dinonaktifkan sehingga dialog tidak terbuka.
    expect(
      find.byWidgetPredicate((Widget w) => w is TextButton && !w.enabled),
      findsOneWidget,
    );
    // Tombol nonaktif tidak membuka dialog. Ketukan pada area itu diteruskan
    // ke tile (membuka detail read-only), sehingga tidak diuji di sini.
    expect(find.text('Kontrol perangkat'), findsNothing);
  });
}
