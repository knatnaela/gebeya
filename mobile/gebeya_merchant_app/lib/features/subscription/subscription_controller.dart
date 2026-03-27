import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  void setExpired({String? message}) {
    state = state.copyWith(isExpired: true, message: message);
  }

  void setActive() {
    state = state.copyWith(isExpired: false, message: null);
  }
}

