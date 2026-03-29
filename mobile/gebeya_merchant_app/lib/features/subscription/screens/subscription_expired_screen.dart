import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../auth/screens/change_password_screen.dart';
import '../subscription_controller.dart';

class SubscriptionExpiredScreen extends ConsumerWidget {
  const SubscriptionExpiredScreen({super.key});

  static const routeLocation = '/subscription-expired';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Icon(Icons.lock_outline, size: 64, color: scheme.primary),
              const SizedBox(height: 24),
              Text(
                'Subscription inactive',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                state.message ??
                    'Trial subscription has expired. Please contact the platform owner to extend your trial or activate your subscription.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Change password',
                onPressed: () => context.push(ChangePasswordScreen.routeLocation),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                child: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
