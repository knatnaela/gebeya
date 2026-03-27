import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/product.dart';
import 'dto/product_list_response_dto.dart';

part 'products_state.freezed.dart';

@freezed
abstract class ProductsState with _$ProductsState {
  const factory ProductsState({
    required bool isLoading,
    String? errorMessage,
    @Default(<Product>[]) List<Product> products,
    PaginationDto? pagination,
    @Default(<String>{}) Set<String> selectedIds,
    // Filters
    String? search,
    String? brandFilter,
    String? sizeFilter,
    num? minPrice,
    num? maxPrice,
    String? stockFilter, // 'all', 'inStock', 'outOfStock', 'lowStock'
    bool? isActiveFilter, // null = all, true = active, false = inactive
    // Stock map (productId -> stock quantity)
    @Default(<String, num>{}) Map<String, num> stockMap,
  }) = _ProductsState;

  factory ProductsState.initial() => const ProductsState(isLoading: true);
}
