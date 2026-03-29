import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/subscription/subscription_controller.dart';
import '../../../features/subscription/subscription_trial_warning_banner.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionControllerProvider);

    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              actions: actions,
            ),
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          if (subscription.showTrialWarning && subscription.daysRemaining != null)
            SubscriptionTrialWarningBanner(
              daysRemaining: subscription.daysRemaining!,
              trialEndDate: subscription.trialEndDate,
            ),
          Expanded(
            child: Padding(
              padding: padding,
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}
