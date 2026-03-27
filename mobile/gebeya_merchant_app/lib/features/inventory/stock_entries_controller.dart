import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../products/dto/product_list_response_dto.dart';
import 'dto/add_stock_dto.dart';
import 'dto/transfer_stock_dto.dart';
import 'inventory_repository.dart';
import 'inventory_controller.dart';
import 'stock_entries_state.dart';

final stockEntriesControllerProvider =
    NotifierProvider<StockEntriesController, StockEntriesState>(StockEntriesController.new);

class StockEntriesController extends Notifier<StockEntriesState> {
  bool _isRefreshing = false;

  @override
  StockEntriesState build() {
    final initial = StockEntriesState.initial();
    Future.microtask(refresh);
    return initial;
  }

  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    state = state.copyWith(isLoading: true, errorMessage: null, entries: []);

    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final result = await repo.fetchEntries(
        productId: state.productIdFilter,
        locationId: state.locationIdFilter,
        page: 1,
        limit: 20,
      );

      state = state.copyWith(
        isLoading: false,
        entries: result.entries,
        pagination: result.pagination,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      debugPrint('Error refreshing stock entries: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> loadMore() async {
    final pagination = state.pagination;
    if (pagination == null) return;
    if (state.isLoadingMore) return;
    if (pagination.page >= pagination.totalPages) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final result = await repo.fetchEntries(
        productId: state.productIdFilter,
        locationId: state.locationIdFilter,
        page: pagination.page + 1,
        limit: pagination.limit,
      );

      state = state.copyWith(
        isLoadingMore: false,
        entries: [...state.entries, ...result.entries],
        pagination: result.pagination,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, errorMessage: e.toString());
    }
  }

  Future<void> setFilters({
    String? productIdFilter,
    String? locationIdFilter,
  }) async {
    // Only update if filters actually changed
    if (state.productIdFilter == productIdFilter &&
        state.locationIdFilter == locationIdFilter) {
      return;
    }

    state = state.copyWith(
      productIdFilter: productIdFilter,
      locationIdFilter: locationIdFilter,
      entries: [],
      pagination: null,
    );

    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final result = await repo.fetchEntries(
        productId: productIdFilter,
        locationId: locationIdFilter,
        page: 1,
        limit: 20,
      );

      state = state.copyWith(isLoading: false, entries: result.entries, pagination: result.pagination);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> addStock(AddStockDto payload) async {
    try {
      final repo = ref.read(inventoryRepositoryProvider);
      await repo.addStock(payload);
      await refresh();
      // Also refresh inventory summary
      ref.read(inventoryControllerProvider.notifier).refreshSummary();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> transferStock(TransferStockDto payload) async {
    try {
      final repo = ref.read(inventoryRepositoryProvider);
      await repo.transferStock(payload);
      await refresh();
      // Also refresh inventory summary
      ref.read(inventoryControllerProvider.notifier).refreshSummary();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }
}
