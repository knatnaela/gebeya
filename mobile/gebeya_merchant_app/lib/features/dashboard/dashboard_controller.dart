import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dashboard_repository.dart';
import 'dashboard_state.dart';

final dashboardControllerProvider =
    NotifierProvider<DashboardController, DashboardState>(
  DashboardController.new,
);

class DashboardController extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    final initial = DashboardState.initial();
    // IMPORTANT: don't read `state` during `build()` (it isn't initialized yet).
    // Schedule initial load after build completes.
    Future.microtask(refresh);
    return initial;
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repo = ref.read(dashboardRepositoryProvider);

      final inventoryFuture = repo.fetchInventorySummary();
      final analyticsFuture = repo.fetchSalesAnalytics(
        startDate: state.startDate,
        endDate: state.endDate,
      );

      final inventory = await inventoryFuture;
      final analytics = await analyticsFuture;

      state = state.copyWith(
        isLoading: false,
        inventorySummary: inventory,
        salesAnalytics: analytics,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> setDateRange({DateTime? startDate, DateTime? endDate}) async {
    state = state.copyWith(startDate: startDate, endDate: endDate);
    await refresh();
  }

  Future<void> setLastDays(int days) async {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    await setDateRange(startDate: start, endDate: end);
  }

  Future<void> clearDateRange() async {
    await setDateRange(startDate: null, endDate: null);
  }
}

