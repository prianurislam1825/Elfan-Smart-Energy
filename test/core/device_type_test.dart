import 'package:flutter_test/flutter_test.dart';

import 'package:elfan_mobile/core/utils/device_type.dart';

void main() {
  group('deviceTypeInfoFor', () {
    test('memetakan kategori socket cz', () {
      final DeviceTypeInfo info = deviceTypeInfoFor(
        category: 'cz',
        type: 'socket',
        channelCount: 1,
      );

      expect(info.label, 'Smart Socket');
    });

    test('membedakan sakelar satu kanal dan banyak kanal', () {
      final DeviceTypeInfo single = deviceTypeInfoFor(
        category: 'kg',
        type: 'switch',
        channelCount: 1,
      );
      final DeviceTypeInfo multi = deviceTypeInfoFor(
        category: 'kg',
        type: 'switch',
        channelCount: 4,
      );

      expect(single.label, 'Sakelar Dinding');
      expect(multi.label, 'Sakelar 4 kanal');
      expect(single.icon, isNot(multi.icon));
    });

    test('memetakan smart plug tdq dan remote IR', () {
      expect(
        deviceTypeInfoFor(category: 'tdq', type: 'plug', channelCount: 1).label,
        'Smart Plug+',
      );
      expect(
        deviceTypeInfoFor(
          category: 'wnykq',
          type: 'ir_remote',
          channelCount: 0,
        ).label,
        'Remote IR Universal',
      );
      expect(
        deviceTypeInfoFor(category: 'qt', type: 'ir_ac', channelCount: 0).label,
        'Perangkat IR',
      );
    });

    test('tidak mengarang label untuk kategori yang tidak terdokumentasi', () {
      final DeviceTypeInfo info = deviceTypeInfoFor(
        category: 'dj',
        type: 'curtain_switch',
        channelCount: 1,
      );

      expect(info.label, 'Curtain switch');
    });

    test('menampilkan label netral saat tipe dan kategori kosong', () {
      final DeviceTypeInfo info = deviceTypeInfoFor(
        category: '',
        type: '',
        channelCount: 0,
      );

      expect(info.label, 'Perangkat');
    });
  });
}
