import 'package:flutter/material.dart';

import 'app_routes.dart';

/// Lima menu utama ELFAN.
///
/// Sumber tunggal untuk label, ikon, dan path, sehingga bottom navigation,
/// navigation rail, dan router tidak pernah berbeda.
enum AppDestination {
  home(
    label: 'Home',
    path: AppRoutes.home,
    icon: Icons.space_dashboard_outlined,
    selectedIcon: Icons.space_dashboard_rounded,
  ),
  devices(
    label: 'Perangkat',
    path: AppRoutes.devices,
    icon: Icons.devices_other_outlined,
    selectedIcon: Icons.devices_other_rounded,
  ),
  voice(
    label: 'Voice',
    path: AppRoutes.voice,
    icon: Icons.mic_none_rounded,
    selectedIcon: Icons.mic_rounded,
  ),
  cctv(
    label: 'CCTV',
    path: AppRoutes.cctv,
    icon: Icons.videocam_outlined,
    selectedIcon: Icons.videocam_rounded,
  ),
  energy(
    label: 'Energi',
    path: AppRoutes.energy,
    icon: Icons.bolt_outlined,
    selectedIcon: Icons.bolt_rounded,
  );

  const AppDestination({
    required this.label,
    required this.path,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final String path;
  final IconData icon;
  final IconData selectedIcon;
}
