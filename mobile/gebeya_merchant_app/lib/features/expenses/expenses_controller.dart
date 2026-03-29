import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/expense_category.dart';
import 'expenses_repository.dart';
import 'expenses_state.dart';

final expensesControllerProvider =
    NotifierProvider<ExpensesController, ExpensesState>(ExpensesController.new);

class ExpensesController extends Notifier<ExpensesState> {
  bool _isRefreshing = false;
  bool _loadMoreInFlight = false;

  @override
  ExpensesState build() {
    final initial = ExpensesState.initial();
    Future.microtask(refresh);
    return initial;
  }

  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repo = ref.read(expensesRepositoryProvider);
      final result = await repo.fetchExpenses(
        startDate: state.startDate,
        endDate: state.endDate,
        category: state.categoryFilter,
        page: 1,
        limit: 20,
      );

      state = state.copyWith(
        isLoading: false,
        expenses: result.expenses,
        pagination: result.pagination,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> loadMore() async {
    final pagination = state.pagination;
    if (pagination == null) return;
    if (state.isLoading || state.isLoadingMore || _loadMoreInFlight) return;
    if (pagination.page >= pagination.totalPages) return;

    _loadMoreInFlight = true;
    state = state.copyWith(isLoadingMore: true);

    try {
      final repo = ref.read(expensesRepositoryProvider);
      final result = await repo.fetchExpenses(
        startDate: state.startDate,
        endDate: state.endDate,
        category: state.categoryFilter,
        page: pagination.page + 1,
        limit: pagination.limit,
      );

      final merged = [...state.expenses, ...result.expenses];
      state = state.copyWith(
        isLoadingMore: false,
        expenses: merged,
        pagination: result.pagination,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, errorMessage: e.toString());
    } finally {
      _loadMoreInFlight = false;
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

  Future<void> setThisMonth() async {
    final now = DateTime.now();
    await setDateRange(startDate: DateTime(now.year, now.month, 1), endDate: now);
  }

  Future<void> clearDateRange() async {
    await setDateRange(startDate: null, endDate: null);
  }

  Future<void> setCategoryFilter(ExpenseCategory? category) async {
    state = state.copyWith(categoryFilter: category);
    await refresh();
  }
}
