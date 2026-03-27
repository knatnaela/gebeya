import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

class _HomeShellState extends ConsumerState<HomeShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (idx) =>
            widget.navigationShell.goBranch(idx, initialLocation: idx == widget.navigationShell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(AppIcons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(AppIcons.products), label: 'Products'),
          NavigationDestination(icon: Icon(AppIcons.inventory), label: 'Inventory'),
          NavigationDestination(icon: Icon(AppIcons.sales), label: 'Sales'),
          NavigationDestination(icon: Icon(AppIcons.more), label: 'More'),
        ],
      ),
    );
  }
}
