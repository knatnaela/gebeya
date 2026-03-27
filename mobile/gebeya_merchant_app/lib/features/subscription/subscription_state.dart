class SubscriptionState {
  const SubscriptionState({
    required this.isExpired,
    this.message,
  });

  final bool isExpired;
  final String? message;

  SubscriptionState copyWith({bool? isExpired, String? message}) {
    return SubscriptionState(
      isExpired: isExpired ?? this.isExpired,
      message: message ?? this.message,
    );
  }

  static const initial = SubscriptionState(isExpired: false);
}

