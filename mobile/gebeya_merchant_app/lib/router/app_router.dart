import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_controller.dart';
import '../core/auth/auth_state.dart';
import '../features/auth/screens/change_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/merchant_signup_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/inventory/screens/add_stock_screen.dart';
import '../features/inventory/screens/inventory_transactions_screen.dart';
import '../features/inventory/screens/stock_entries_screen.dart';
import '../features/products/screens/product_create_edit_screen.dart';
import '../features/inventory/screens/adjust_stock_screen.dart';
import '../features/inventory/screens/transfer_stock_screen.dart';
import '../features/products/screens/product_picker_screen.dart';
import '../features/design_system/screens/design_showcase_screen.dart';
import '../features/sales/screens/new_sale_screen.dart';
import '../features/sales/screens/sale_detail_screen.dart';
import '../features/shell/screens/home_shell.dart';
import '../features/shell/screens/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(_routerNotifierProvider);

  return GoRouter(
    initialLocation: SplashScreen.routeLocation,
    refreshListenable: routerNotifier,
    routes: [
      GoRoute(path: SplashScreen.routeLocation, builder: (context, state) => const SplashScreen()),
      GoRoute(path: LoginScreen.routeLocation, builder: (context, state) => const LoginScreen()),
      GoRoute(path: MerchantSignupScreen.routeLocation, builder: (context, state) => const MerchantSignupScreen()),
      GoRoute(path: ChangePasswordScreen.routeLocation, builder: (context, state) => const ChangePasswordScreen()),
      GoRoute(
        path: ProductCreateEditScreen.routeLocation,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return ProductCreateEditScreen(productId: id);
        },
      ),
      GoRoute(
        path: InventoryTransactionsScreen.routeLocation,
        builder: (context, state) => const InventoryTransactionsScreen(),
      ),
      GoRoute(path: StockEntriesScreen.routeLocation, builder: (context, state) => const StockEntriesScreen()),
      GoRoute(path: AddStockScreen.routeLocation, builder: (context, state) => const AddStockScreen()),
      GoRoute(path: AdjustStockScreen.routeLocation, builder: (context, state) => const AdjustStockScreen()),
      GoRoute(path: TransferStockScreen.routeLocation, builder: (context, state) => const TransferStockScreen()),
      GoRoute(path: ProductPickerScreen.routeLocation, builder: (context, state) => const ProductPickerScreen()),
      GoRoute(path: DesignShowcaseScreen.routeLocation, builder: (context, state) => const DesignShowcaseScreen()),
      GoRoute(path: NewSaleScreen.routeLocation, builder: (context, state) => const NewSaleScreen()),
      GoRoute(
        path: '/app/sales/detail/:saleId',
        builder: (context, state) {
          final id = state.pathParameters['saleId']!;
          return SaleDetailScreen(saleId: id);
        },
      ),
      HomeShell.route,
    ],
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loc = state.matchedLocation;

      final isLoading = auth is AuthLoading;
      final isAuthed = auth is AuthAuthenticated;
      final needsPassword = auth is AuthRequiresPasswordChange;

      final isAuthRoute = loc == LoginScreen.routeLocation || loc == MerchantSignupScreen.routeLocation;
      final isSplash = loc == SplashScreen.routeLocation;
      final isChangePassword = loc == ChangePasswordScreen.routeLocation;
      final isDesignShowcase = loc == DesignShowcaseScreen.routeLocation;

      if (isDesignShowcase) return null;

      if (isLoading) {
        return isSplash ? null : SplashScreen.routeLocation;
      }

      if (needsPassword) {
        return isChangePassword ? null : ChangePasswordScreen.routeLocation;
      }

      if (!isAuthed) {
        return isAuthRoute ? null : LoginScreen.routeLocation;
      }

      // Authenticated
      if (isSplash || isAuthRoute || isChangePassword) {
        return DashboardScreen.routeLocation;
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(body: Center(child: Text('Route not found: ${state.matchedLocation}'))),
  );
});

final _routerNotifierProvider = Provider<_RouterNotifier>((ref) {
  return _RouterNotifier(ref);
});

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this.ref) {
    ref.listen<AuthState>(authControllerProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
}
