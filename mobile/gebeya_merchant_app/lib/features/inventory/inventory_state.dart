import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/inventory_summary.dart';
import '../../models/inventory_transaction.dart';
import '../products/dto/product_list_response_dto.dart';

part 'inventory_state.freezed.dart';

@freezed
abstract class InventoryState with _$InventoryState {
  const factory InventoryState({
    required bool isLoading,
    String? errorMessage,
    InventorySummary? summary,
    @Default(<InventoryTransaction>[]) List<InventoryTransaction> recentTransactions,
    @Default(<InventoryTransaction>[]) List<InventoryTransaction> allTransactions,
    PaginationDto? pagination,
    // Filters for transactions
    String? productIdFilter,
    InventoryTransactionType? typeFilter,
    DateTime? startDateFilter,
    DateTime? endDateFilter,
  }) = _InventoryState;

  factory InventoryState.initial() => const InventoryState(isLoading: true);
}
