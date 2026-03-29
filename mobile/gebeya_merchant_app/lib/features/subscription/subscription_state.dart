class SubscriptionState {
  const SubscriptionState({
    required this.isActive,
    required this.isExpired,
    this.status,
    this.trialEndDate,
    this.daysRemaining,
    this.message,
  });

  /// From API `isActive`; optimistic `true` until first [refresh].
  final bool isActive;

  /// True when trial/subscription is not active or when a 403 interceptor fired.
  final bool isExpired;

  final String? status;
  final DateTime? trialEndDate;
  final int? daysRemaining;

  /// Optional message (e.g. from 403 body).
  final String? message;

  bool get showTrialWarning =>
      isActive &&
      !isExpired &&
      daysRemaining != null &&
      daysRemaining! > 0 &&
      daysRemaining! <= 7;

  SubscriptionState copyWith({
    bool? isActive,
    bool? isExpired,
    String? status,
    DateTime? trialEndDate,
    int? daysRemaining,
    String? message,
  }) {
    return SubscriptionState(
      isActive: isActive ?? this.isActive,
      isExpired: isExpired ?? this.isExpired,
      status: status ?? this.status,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      message: message ?? this.message,
    );
  }

  static const initial = SubscriptionState(isActive: true, isExpired: false);
}
