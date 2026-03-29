import 'package:flutter/material.dart';

import '../../core/ui/theme/app_icons.dart';

class SubscriptionTrialWarningBanner extends StatelessWidget {
  const SubscriptionTrialWarningBanner({
    super.key,
    required this.daysRemaining,
    this.trialEndDate,
  });

  final int daysRemaining;
  final DateTime? trialEndDate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dateLabel = trialEndDate != null
        ? ' (ends ${trialEndDate!.toIso8601String().split('T').first})'
        : '';

    return Material(
      color: scheme.tertiaryContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(AppIcons.warning, color: scheme.onTertiaryContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  daysRemaining == 1
                      ? 'Your trial ends tomorrow.$dateLabel'
                      : 'Your trial ends in $daysRemaining days.$dateLabel',
                  style: TextStyle(
                    color: scheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
