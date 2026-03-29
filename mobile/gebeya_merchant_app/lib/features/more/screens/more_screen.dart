import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/permissions/merchant_feature_slugs.dart';
import '../../../core/permissions/merchant_permissions_provider.dart';
import '../../../core/ui/theme/app_icons.dart';
import '../../../core/ui/widgets/app_scaffold.dart';
import '../../../models/current_user.dart';
import '../../account/screens/account_screen.dart';
import '../../auth/screens/change_password_screen.dart';
import '../../expenses/screens/expenses_screen.dart';
import '../../locations/screens/locations_list_screen.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  static const routeLocation = '/app/more';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final perms = ref.watch(merchantPermissionsProvider);
    final CurrentUser? user = switch (auth) {
      AuthAuthenticated(:final user) => user,
      AuthRequiresPasswordChange(:final user) => user,
      _ => null,
    };

    return AppScaffold(
      title: 'More',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.firstName ?? ''} ${user.lastName ?? ''}'
                            .trim()
                            .isEmpty
                        ? 'Signed in'
                        : '${user.firstName ?? ''} ${user.lastName ?? ''}'
                              .trim(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          if (perms.hasFeature(MerchantFeatureSlugs.inventoryView))
            _MoreTile(
              icon: AppIcons.location,
              title: 'Locations',
              subtitle: 'Shops and warehouses',
              onTap: () => context.push(LocationsListScreen.routeLocation),
            ),
          if (perms.hasFeature(MerchantFeatureSlugs.salesView))
            _MoreTile(
              icon: AppIcons.money,
              title: 'Expenses',
              subtitle: 'Track business spending',
              onTap: () => context.push(ExpensesScreen.routeLocation),
            ),
          _MoreTile(
            icon: AppIcons.user,
            title: 'Account',
            subtitle: 'Edit your name',
            onTap: () => context.push(AccountScreen.routeLocation),
          ),
          _MoreTile(
            icon: AppIcons.settings,
            title: 'Change password',
            subtitle: 'Update your account password',
            onTap: () => context.push(ChangePasswordScreen.routeLocation),
          ),
          const Divider(height: 1),
          _MoreTile(
            icon: AppIcons.logout,
            title: 'Log out',
            subtitle: 'Sign out on this device',
            onTap: () => _confirmLogout(context, ref),
            danger: true,
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? Theme.of(context).colorScheme.error : null;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: danger ? TextStyle(color: color) : null),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Log out?'),
      content: const Text('You will need to sign in again to use the app.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Log out'),
        ),
      ],
    ),
  );
  if (ok == true) {
    await ref.read(authControllerProvider.notifier).logout();
  }
}
