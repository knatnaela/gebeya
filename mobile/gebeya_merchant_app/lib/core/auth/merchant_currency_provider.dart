import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';
import 'auth_state.dart';

/// ISO 4217 from [CurrentUser.merchantCurrency] (nested `merchants` on `/auth/me`).
final merchantCurrencyProvider = Provider<String>((ref) {
  final auth = ref.watch(authControllerProvider);
  return auth.maybeWhen(
    requiresPasswordChange: (user) => user?.merchantCurrency ?? 'ETB',
    authenticated: (user) => user.merchantCurrency,
    orElse: () => 'ETB',
  );
});
