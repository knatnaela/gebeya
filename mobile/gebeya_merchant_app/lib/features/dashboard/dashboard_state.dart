import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/inventory_summary.dart';
import '../../models/sales_analytics.dart';

part 'dashboard_state.freezed.dart';

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    required bool isLoading,
    String? errorMessage,
    DateTime? startDate,
    DateTime? endDate,
    InventorySummary? inventorySummary,
    SalesAnalytics? salesAnalytics,
  }) = _DashboardState;

  factory DashboardState.initial() => const DashboardState(isLoading: true);
}

