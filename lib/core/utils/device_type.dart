import 'package:flutter/material.dart';

/// Pemetaan kategori perangkat ke label dan ikon yang mudah dipahami.
///
/// Sumber pemetaan adalah `docs/device-reference/`:
/// - `cz` — smart socket / smart plug Tuya (BARDI Smart Wall Socket, Smart plug),
/// - `kg` — wall switch satu sampai empat gang (BARDI Wallswitch, S604),
/// - `tdq` — T34-Smart Plug+,
/// - `wnykq` — remote IR universal (万能红外遥控器),
/// - `qt` — perangkat IR turunan controller (红外空调 / 红外风扇).
///
/// Kategori yang tidak tercatat pada referensi tidak dipetakan secara paksa:
/// labelnya diambil dari field `type` backend apa adanya sehingga UI tidak
/// mengklaim kemampuan perangkat yang belum terdokumentasi.
@immutable
class DeviceTypeInfo {
  const DeviceTypeInfo({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

DeviceTypeInfo deviceTypeInfoFor({
  required String category,
  required String type,
  required int channelCount,
}) {
  final String normalizedCategory = category.trim().toLowerCase();

  switch (normalizedCategory) {
    case 'cz':
      return const DeviceTypeInfo(
        label: 'Smart Socket',
        icon: Icons.outlet_rounded,
      );
    case 'kg':
      if (channelCount > 1) {
        return DeviceTypeInfo(
          label: 'Sakelar $channelCount kanal',
          icon: Icons.view_module_outlined,
        );
      }
      return const DeviceTypeInfo(
        label: 'Sakelar Dinding',
        icon: Icons.toggle_on_outlined,
      );
    case 'tdq':
      return const DeviceTypeInfo(
        label: 'Smart Plug+',
        icon: Icons.power_rounded,
      );
    case 'wnykq':
      return const DeviceTypeInfo(
        label: 'Remote IR Universal',
        icon: Icons.settings_remote_rounded,
      );
    case 'qt':
      return const DeviceTypeInfo(
        label: 'Perangkat IR',
        icon: Icons.sensors_rounded,
      );
  }

  // Kategori lain tidak didokumentasikan; tampilkan tipe dari backend.
  return DeviceTypeInfo(
    label: _humanize(type.isNotEmpty ? type : category),
    icon: Icons.device_hub_rounded,
  );
}

/// Mengubah `multi_channel_switch` menjadi `Multi channel switch`.
String _humanize(String raw) {
  final String trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return 'Perangkat';
  }
  final String spaced = trimmed.replaceAll(RegExp(r'[_-]+'), ' ');
  return spaced[0].toUpperCase() + spaced.substring(1);
}
