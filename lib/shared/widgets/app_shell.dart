import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_destinations.dart';
import '../../core/theme/color_tokens.dart';
import '../../core/utils/responsive.dart';
import 'elfan_brand.dart';

/// Kerangka utama ELFAN.
///
/// Memakai [StatefulNavigationShell] dari `StatefulShellRoute.indexedStack`
/// sehingga setiap tab memiliki navigator dan state sendiri: perpindahan tab
/// tidak menghapus posisi scroll maupun sub-route tab lain.
///
/// Layout responsif:
/// - lebar < 900: bottom navigation (mobile-first, docs/05),
/// - lebar >= 900: navigation rail di sisi kiri (tablet/foldable).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      // Kembali ke halaman awal tab saat tab yang sama ditekan lagi.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool useRail = Responsive.useNavigationRail(context);

    return Scaffold(
      body: useRail
          ? SafeArea(
              child: Row(
                children: <Widget>[
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      color: ColorTokens.surface,
                      border: Border(
                        right: BorderSide(color: ColorTokens.border),
                      ),
                    ),
                    child: NavigationRail(
                      selectedIndex: navigationShell.currentIndex,
                      onDestinationSelected: _onDestinationSelected,
                      minWidth: 84,
                      leading: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: ElfanBrandMark(size: 36),
                      ),
                      destinations: <NavigationRailDestination>[
                        for (final AppDestination destination
                            in AppDestination.values)
                          NavigationRailDestination(
                            icon: Icon(destination.icon),
                            selectedIcon: Icon(destination.selectedIcon),
                            label: Text(destination.label),
                          ),
                      ],
                    ),
                  ),
                  Expanded(child: navigationShell),
                ],
              ),
            )
          : navigationShell,
      bottomNavigationBar: useRail
          ? null
          : NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: <NavigationDestination>[
                for (final AppDestination destination in AppDestination.values)
                  NavigationDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: destination.label,
                    tooltip: destination.label,
                  ),
              ],
            ),
    );
  }
}
