import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/permissions/merchant_feature_slugs.dart';
import '../../../core/permissions/merchant_permissions_provider.dart';
import '../../../core/ui/theme/app_icons.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../inventory/screens/inventory_screen.dart';
import '../../more/screens/more_screen.dart';
import '../../products/screens/products_screen.dart';
import '../../sales/screens/sales_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static StatefulShellRoute get route {
    return StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => HomeShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: DashboardScreen.routeLocation, builder: (context, state) => const DashboardScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: ProductsScreen.routeLocation, builder: (context, state) => const ProductsScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: InventoryScreen.routeLocation, builder: (context, state) => const InventoryScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: SalesScreen.routeLocation, builder: (context, state) => const SalesScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: MoreScreen.routeLocation, builder: (context, state) => const MoreScreen())],
        ),
      ],
    );
  }

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _NavEntry {
  const _NavEntry({required this.branchIndex, required this.icon, required this.label});

  final int branchIndex;
  final IconData icon;
  final String label;
}

class _HomeShellState extends ConsumerState<HomeShell> {
  @override
  Widget build(BuildContext context) {
    final perms = ref.watch(merchantPermissionsProvider);

    final entries = <_NavEntry>[
      const _NavEntry(branchIndex: 0, icon: AppIcons.dashboard, label: 'Dashboard'),
      if (perms.hasFeature(MerchantFeatureSlugs.productsView))
        const _NavEntry(branchIndex: 1, icon: AppIcons.products, label: 'Products'),
      if (perms.hasFeature(MerchantFeatureSlugs.inventoryView))
        const _NavEntry(branchIndex: 2, icon: AppIcons.inventory, label: 'Inventory'),
      if (perms.hasFeature(MerchantFeatureSlugs.salesView))
        const _NavEntry(branchIndex: 3, icon: AppIcons.sales, label: 'Sales'),
      const _NavEntry(branchIndex: 4, icon: AppIcons.more, label: 'More'),
    ];

    final branchIndices = entries.map((e) => e.branchIndex).toList();
    final current = widget.navigationShell.currentIndex;
    var selected = branchIndices.indexOf(current);
    if (selected < 0) selected = 0;

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (i) {
          widget.navigationShell.goBranch(
            branchIndices[i],
            initialLocation: branchIndices[i] == widget.navigationShell.currentIndex,
          );
        },
        destinations: [
          for (final e in entries)
            NavigationDestination(icon: Icon(e.icon), label: e.label),
        ],
      ),
    );
  }
}
