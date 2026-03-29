import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'subscription_repository.dart';
import 'subscription_state.dart';

final subscriptionControllerProvider =
    NotifierProvider<SubscriptionController, SubscriptionState>(
  SubscriptionController.new,
);

class SubscriptionController extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() => SubscriptionState.initial;

  void clear() {
    state = SubscriptionState.initial;
  }

  /// Proactive status from [GET /subscriptions/status].
  Future<void> refresh() async {
    try {
      final dto = await ref.read(subscriptionRepositoryProvider).fetchStatus();
      applyFromDto(dto);
    } catch (_) {
      // Do not lock the app if status cannot be loaded; API calls still enforce.
    }
  }

  void applyFromDto(SubscriptionStatusDto dto) {
    state = SubscriptionState(
      isActive: dto.isActive,
      isExpired: !dto.isActive,
      status: dto.status,
      trialEndDate: dto.trialEndDate,
      daysRemaining: dto.daysRemaining,
      message: null,
    );
  }

  void setExpired({String? message}) {
    state = state.copyWith(
      isExpired: true,
      isActive: false,
      message: message,
    );
  }

  void setActive() {
    state = state.copyWith(isExpired: false, isActive: true, message: null);
  }
}
