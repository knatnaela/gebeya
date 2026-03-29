import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_controller.dart';
import '../core/auth/auth_state.dart';
import '../core/permissions/merchant_permissions_provider.dart';
import '../core/permissions/route_permission.dart';
import '../features/account/screens/account_screen.dart';
import '../features/auth/screens/change_password_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_gateway_verify_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/merchant_signup_screen.dart';
import '../features/auth/screens/reset_password_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/inventory/screens/add_stock_screen.dart';
import '../features/inventory/screens/inventory_transactions_screen.dart';
import '../features/inventory/screens/stock_entries_screen.dart';
import '../features/products/screens/product_create_edit_screen.dart';
import '../features/inventory/screens/adjust_stock_screen.dart';
import '../features/inventory/screens/transfer_stock_screen.dart';
import '../features/products/screens/product_picker_screen.dart';
import '../features/design_system/screens/design_showcase_screen.dart';
import '../features/expenses/screens/expense_form_screen.dart';
import '../features/expenses/screens/expenses_screen.dart';
import '../features/locations/screens/location_form_screen.dart';
import '../features/locations/screens/locations_list_screen.dart';
import '../features/sales/screens/new_sale_screen.dart';
import '../features/sales/screens/sale_detail_screen.dart';
import '../features/shell/screens/home_shell.dart';
import '../features/shell/screens/splash_screen.dart';
import '../features/subscription/screens/subscription_expired_screen.dart';
import '../features/subscription/subscription_controller.dart';
import '../features/subscription/subscription_state.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(_routerNotifierProvider);

  return GoRouter(
    initialLocation: SplashScreen.routeLocation,
    refreshListenable: routerNotifier,
    routes: [
      GoRoute(
        path: SplashScreen.routeLocation,
        builder: (context, state) => const SplashScreen(),
      ),
      // More specific path must be registered before `/login` so navigation resolves correctly.
      GoRoute(
        path: LoginGatewayVerifyScreen.routeLocation,
        builder: (context, state) {
          final fromQuery = state.uri.queryParameters['rid'];
          final extra = state.extra;
          final extraId = extra is String ? extra : null;
          final id = (extraId != null && extraId.isNotEmpty)
              ? extraId
              : (fromQuery != null && fromQuery.isNotEmpty ? fromQuery : null);
          return LoginGatewayVerifyScreen(requestId: id);
        },
      ),
      GoRoute(
        path: LoginScreen.routeLocation,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: MerchantSignupScreen.routeLocation,
        builder: (context, state) => const MerchantSignupScreen(),
      ),
      GoRoute(
        path: ForgotPasswordScreen.routeLocation,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: ResetPasswordScreen.routeLocation,
        builder: (context, state) => ResetPasswordScreen(
          initialToken: state.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: ChangePasswordScreen.routeLocation,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AccountScreen.routeLocation,
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: SubscriptionExpiredScreen.routeLocation,
        builder: (context, state) => const SubscriptionExpiredScreen(),
      ),
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
      GoRoute(
        path: StockEntriesScreen.routeLocation,
        builder: (context, state) => const StockEntriesScreen(),
      ),
      GoRoute(
        path: AddStockScreen.routeLocation,
        builder: (context, state) => const AddStockScreen(),
      ),
      GoRoute(
        path: AdjustStockScreen.routeLocation,
        builder: (context, state) => const AdjustStockScreen(),
      ),
      GoRoute(
        path: TransferStockScreen.routeLocation,
        builder: (context, state) => const TransferStockScreen(),
      ),
      GoRoute(
        path: ProductPickerScreen.routeLocation,
        builder: (context, state) => const ProductPickerScreen(),
      ),
      GoRoute(
        path: DesignShowcaseScreen.routeLocation,
        builder: (context, state) => const DesignShowcaseScreen(),
      ),
      GoRoute(
        path: NewSaleScreen.routeLocation,
        builder: (context, state) => const NewSaleScreen(),
      ),
      GoRoute(
        path: LocationsListScreen.routeLocation,
        builder: (context, state) => const LocationsListScreen(),
      ),
      GoRoute(
        path: LocationFormScreen.routeLocation,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return LocationFormScreen(locationId: id);
        },
      ),
      GoRoute(
        path: ExpensesScreen.routeLocation,
        builder: (context, state) => const ExpensesScreen(),
      ),
      GoRoute(
        path: ExpenseFormScreen.routeLocation,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return ExpenseFormScreen(expenseId: id);
        },
      ),
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

      final isAuthRoute =
          loc == LoginScreen.routeLocation ||
          loc == LoginGatewayVerifyScreen.routeLocation ||
          loc == MerchantSignupScreen.routeLocation ||
          loc == ForgotPasswordScreen.routeLocation ||
          loc == ResetPasswordScreen.routeLocation;
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

      final sub = ref.read(subscriptionControllerProvider);

      if (isAuthed && sub.isExpired && !needsPassword) {
        final allowedExpired =
            loc == SubscriptionExpiredScreen.routeLocation ||
            loc == ChangePasswordScreen.routeLocation ||
            loc == AccountScreen.routeLocation;
        if (!allowedExpired) {
          return SubscriptionExpiredScreen.routeLocation;
        }
      }

      if (isAuthed && !sub.isExpired && !needsPassword) {
        final feat = requiredFeatureForMerchantPath(loc);
        if (feat != null && !ref.read(merchantPermissionsProvider).hasFeature(feat)) {
          return DashboardScreen.routeLocation;
        }
      }

      // Authenticated: leave splash/login for home or expired (change-password stays put when opened from More)
      if (isSplash || isAuthRoute) {
        if (sub.isExpired && !needsPassword) {
          return SubscriptionExpiredScreen.routeLocation;
        }
        return DashboardScreen.routeLocation;
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.matchedLocation}')),
    ),
  );
});

final _routerNotifierProvider = Provider<_RouterNotifier>((ref) {
  return _RouterNotifier(ref);
});

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this.ref) {
    ref.listen<AuthState>(authControllerProvider, (_, __) => notifyListeners());
    ref.listen<SubscriptionState>(subscriptionControllerProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
}
