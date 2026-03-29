import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/sale.dart';
import 'sales_repository.dart';
import 'sales_state.dart';

final salesControllerProvider =
    NotifierProvider<SalesController, SalesState>(
  SalesController.new,
);

class SalesController extends Notifier<SalesState> {
  bool _isRefreshing = false;
  bool _loadMoreInFlight = false;

  @override
  SalesState build() {
    final initial = SalesState.initial();
    Future.microtask(refresh);
    return initial;
  }

  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repo = ref.read(salesRepositoryProvider);
      final result = await repo.fetchSales(
        startDate: state.startDate,
        endDate: state.endDate,
        page: 1,
        limit: 20,
      );

      state = state.copyWith(
        isLoading: false,
        sales: result.sales,
        pagination: result.pagination,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
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
      final repo = ref.read(salesRepositoryProvider);
      final result = await repo.fetchSales(
        startDate: state.startDate,
        endDate: state.endDate,
        page: pagination.page + 1,
        limit: pagination.limit,
      );

      final merged = [...state.sales, ...result.sales];
      state = state.copyWith(
        isLoadingMore: false,
        sales: merged,
        pagination: result.pagination,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
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

  Future<void> clearDateRange() async {
    await setDateRange(startDate: null, endDate: null);
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Client-side filter on loaded [sales] (backend list has no search param).
  List<Sale> filteredSales(List<Sale> sales) {
    final q = state.searchQuery.trim().toLowerCase();
    if (q.isEmpty) return sales;
    return sales.where((s) {
      if (s.id.toLowerCase().contains(q)) return true;
      if ((s.customerName ?? '').toLowerCase().contains(q)) return true;
      if ((s.customerPhone ?? '').toLowerCase().contains(q)) return true;
      if ((s.customerPhoneNationalNumber ?? '').toLowerCase().contains(q)) {
        return true;
      }
      if ((s.customerPhoneCountryIso ?? '').toLowerCase().contains(q)) {
        return true;
      }
      final seller = s.seller;
      if (seller != null) {
        final name = '${seller.firstName ?? ''} ${seller.lastName ?? ''}'.trim().toLowerCase();
        if (name.contains(q)) return true;
        if ((seller.email ?? '').toLowerCase().contains(q)) return true;
      }
      return false;
    }).toList();
  }
}
