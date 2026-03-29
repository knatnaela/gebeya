import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_state.dart';
import 'merchant_permissions.dart';

final merchantPermissionsProvider = Provider<MerchantPermissions>((ref) {
  final auth = ref.watch(authControllerProvider);
  if (auth is AuthAuthenticated) {
    return MerchantPermissions.fromUser(auth.user);
  }
  if (auth is AuthRequiresPasswordChange) {
    final u = auth.user;
    if (u != null) return MerchantPermissions.fromUser(u);
  }
  return MerchantPermissions.none();
});
