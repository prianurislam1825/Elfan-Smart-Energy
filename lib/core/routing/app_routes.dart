/// Path dan nama route aplikasi.
///
/// Lima route utama adalah menu bottom navigation sesuai
/// `docs/05_UI_UX_GUIDELINES.md`. Sub-route fitur (detail perangkat, player
/// CCTV, dan seterusnya) ditambahkan sebagai `routes` anak pada branch yang
/// sesuai agar state tab tetap terjaga.
abstract final class AppRoutes {
  static const String root = '/';
  static const String home = '/home';
  static const String devices = '/devices';
  static const String voice = '/voice';
  static const String cctv = '/cctv';
  static const String energy = '/energy';

  static const String initial = home;
}

abstract final class AppRouteNames {
  static const String home = 'home';
  static const String devices = 'devices';
  static const String voice = 'voice';
  static const String cctv = 'cctv';
  static const String energy = 'energy';
}
