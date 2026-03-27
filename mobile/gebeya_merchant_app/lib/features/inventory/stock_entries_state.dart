import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../models/inventory_entry.dart';
import '../products/dto/product_list_response_dto.dart';

part 'stock_entries_state.freezed.dart';

@freezed
abstract class StockEntriesState with _$StockEntriesState {
  const factory StockEntriesState({
    @Default([]) List<InventoryEntry> entries,
    PaginationDto? pagination,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    String? errorMessage,
    String? productIdFilter,
    String? locationIdFilter,
  }) = _StockEntriesState;

  const StockEntriesState._();

  factory StockEntriesState.initial() => const StockEntriesState();
}
