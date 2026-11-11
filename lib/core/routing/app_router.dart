import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cctv/screens/cctv_screen.dart';
import '../../features/dashboard/screens/home_screen.dart';
import '../../features/devices/screens/device_detail_screen.dart';
import '../../features/devices/screens/devices_screen.dart';
import '../../features/energy/screens/energy_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/voice/screens/voice_screen.dart';
import '../../shared/widgets/app_shell.dart';
import 'app_routes.dart';
import 'route_error_screen.dart';

/// Router aplikasi.
///
/// Setiap menu utama menjadi satu [StatefulShellBranch]. Sub-route fitur
/// ditambahkan pada `routes` milik branch yang sesuai, contoh:
///
/// ```dart
/// StatefulShellBranch(routes: [
///   GoRoute(
///     path: AppRoutes.devices,
///     builder: (context, state) => const DevicesScreen(),
///     routes: [
///       GoRoute(path: ':deviceId', builder: ...),
///     ],
///   ),
/// ])
/// ```
final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {
  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.initial,
    redirect: (BuildContext context, GoRouterState state) {
      // Deep link ke root diarahkan ke menu pertama.
      if (state.uri.path == AppRoutes.root) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return AppShell(navigationShell: navigationShell);
            },
        branches: <StatefulShellBranch>[
          _branch(AppRoutes.home, AppRouteNames.home, const HomeScreen()),
          _branch(
            AppRoutes.devices,
            AppRouteNames.devices,
            const DevicesScreen(),
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.deviceDetailSegment,
                name: AppRouteNames.deviceDetail,
                builder: (BuildContext context, GoRouterState state) {
                  return DeviceDetailScreen(
                    deviceId: state.pathParameters['deviceId'] ?? '',
                  );
                },
              ),
            ],
          ),
          _branch(AppRoutes.voice, AppRouteNames.voice, const VoiceScreen()),
          _branch(AppRoutes.cctv, AppRouteNames.cctv, const CctvScreen()),
          _branch(AppRoutes.energy, AppRouteNames.energy, const EnergyScreen()),
        ],
      ),
      // Halaman pendukung di luar bottom navigation (docs/01 §6).
      GoRoute(
        path: AppRoutes.settings,
        name: AppRouteNames.settings,
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsScreen(),
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) {
      return RouteErrorScreen(location: state.uri.toString());
    },
  );

  ref.onDispose(router.dispose);
  return router;
});

StatefulShellBranch _branch(
  String path,
  String name,
  Widget screen, {
  List<RouteBase> routes = const <RouteBase>[],
}) {
  return StatefulShellBranch(
    routes: <RouteBase>[
      GoRoute(
        path: path,
        name: name,
        builder: (BuildContext context, GoRouterState state) => screen,
        routes: routes,
      ),
    ],
  );
}
