import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/inventory_summary.dart';
import '../../models/inventory_transaction.dart';
import '../products/dto/product_list_response_dto.dart';
import 'inventory_repository.dart';
import 'inventory_state.dart';
import 'dto/create_transaction_dto.dart';

final inventoryControllerProvider = NotifierProvider<InventoryController, InventoryState>(InventoryController.new);

class InventoryController extends Notifier<InventoryState> {
  bool _isRefreshing = false;

  @override
  InventoryState build() {
    final initial = InventoryState.initial();
    Future.microtask(refresh);
    return initial;
  }

  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repo = ref.read(inventoryRepositoryProvider);

      // Fetch summary and recent transactions in parallel
      final results = await Future.wait([repo.fetchInventorySummary(), repo.fetchTransactions(page: 1, limit: 10)]);

      final summary = results[0] as InventorySummary?;
      final transactionsResult = results[1] as ({List<InventoryTransaction> transactions, PaginationDto pagination})?;

      if (summary == null || transactionsResult == null) {
        throw Exception('Failed to fetch inventory data');
      }

      state = state.copyWith(
        isLoading: false,
        summary: summary,
        recentTransactions: transactionsResult.transactions,
        allTransactions: transactionsResult.transactions,
        pagination: transactionsResult.pagination,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      debugPrint('Error refreshing inventory: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> refreshSummary() async {
    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final summary = await repo.fetchInventorySummary();
      state = state.copyWith(summary: summary);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> loadMoreTransactions() async {
    final pagination = state.pagination;
    if (pagination == null) return;
    if (state.isLoading) return;
    if (pagination.page >= pagination.totalPages) return;

    state = state.copyWith(isLoading: true);

    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final result = await repo.fetchTransactions(
        productId: state.productIdFilter,
        type: state.typeFilter,
        startDate: state.startDateFilter,
        endDate: state.endDateFilter,
        page: pagination.page + 1,
        limit: pagination.limit,
      );

      state = state.copyWith(
        isLoading: false,
        allTransactions: [...state.allTransactions, ...result.transactions],
        pagination: result.pagination,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> setFilters({
    String? productIdFilter,
    InventoryTransactionType? typeFilter,
    DateTime? startDateFilter,
    DateTime? endDateFilter,
  }) async {
    // Only update if filters actually changed
    if (state.productIdFilter == productIdFilter &&
        state.typeFilter == typeFilter &&
        state.startDateFilter == startDateFilter &&
        state.endDateFilter == endDateFilter) {
      return;
    }

    state = state.copyWith(
      productIdFilter: productIdFilter,
      typeFilter: typeFilter,
      startDateFilter: startDateFilter,
      endDateFilter: endDateFilter,
      allTransactions: [],
      pagination: null,
    );

    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final result = await repo.fetchTransactions(
        productId: productIdFilter,
        type: typeFilter,
        startDate: startDateFilter,
        endDate: endDateFilter,
        page: 1,
        limit: 20,
      );

      state = state.copyWith(isLoading: false, allTransactions: result.transactions, pagination: result.pagination);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> createAdjustment(CreateTransactionDto payload) async {
    try {
      final repo = ref.read(inventoryRepositoryProvider);
      await repo.createTransaction(payload);
      await refresh();
      await refreshSummary();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }
}
