import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/sale.dart';
import '../products/dto/product_list_response_dto.dart';

part 'sales_state.freezed.dart';

@freezed
abstract class SalesState with _$SalesState {
  const factory SalesState({
    required bool isLoading,
    @Default(false) bool isLoadingMore,
    String? errorMessage,
    @Default(<Sale>[]) List<Sale> sales,
    PaginationDto? pagination,
    DateTime? startDate,
    DateTime? endDate,
    @Default('') String searchQuery,
  }) = _SalesState;

  factory SalesState.initial() => const SalesState(isLoading: true);
}
