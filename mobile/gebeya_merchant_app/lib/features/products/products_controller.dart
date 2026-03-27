import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import 'products_repository.dart';
import 'products_state.dart';
import 'dto/create_product_dto.dart';
import 'dto/update_product_dto.dart';

final productsControllerProvider =
    NotifierProvider<ProductsController, ProductsState>(
  ProductsController.new,
);

class ProductsController extends Notifier<ProductsState> {
  bool _isRefreshing = false;

  @override
  ProductsState build() {
    final initial = ProductsState.initial();
    Future.microtask(refresh);
    return initial;
  }

  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repo = ref.read(productsRepositoryProvider);
      final result = await repo.fetchProducts(
        search: state.search,
        brand: state.brandFilter,
        size: state.sizeFilter,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        lowStock: state.stockFilter == 'lowStock',
        inStock: state.stockFilter == 'inStock',
        outOfStock: state.stockFilter == 'outOfStock',
        isActive: state.isActiveFilter,
        page: 1,
        limit: 20,
      );

      final stockMap = <String, num>{};
      final defaultLocation = await _getDefaultLocation();
      if (defaultLocation != null && result.products.isNotEmpty) {
        try {
          final batch = await repo.fetchProductStockBatch(
            result.products.map((p) => p.id),
            locationId: defaultLocation,
          );
          for (final product in result.products) {
            stockMap[product.id] = batch[product.id] ?? 0;
          }
        } catch (_) {
          for (final product in result.products) {
            stockMap[product.id] = 0;
          }
        }
      } else {
        for (final product in result.products) {
          stockMap[product.id] = 0;
        }
      }

      state = state.copyWith(
        isLoading: false,
        products: result.products,
        pagination: result.pagination,
        stockMap: stockMap,
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
    if (state.isLoading) return;
    if (pagination.page >= pagination.totalPages) return;

    state = state.copyWith(isLoading: true);

    try {
      final repo = ref.read(productsRepositoryProvider);
      final result = await repo.fetchProducts(
        search: state.search,
        brand: state.brandFilter,
        size: state.sizeFilter,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        lowStock: state.stockFilter == 'lowStock',
        inStock: state.stockFilter == 'inStock',
        outOfStock: state.stockFilter == 'outOfStock',
        isActive: state.isActiveFilter,
        page: pagination.page + 1,
        limit: pagination.limit,
      );

      // Fetch stock for new products in parallel
      final stockMap = Map<String, num>.from(state.stockMap);
      final defaultLocation = await _getDefaultLocation();
      if (defaultLocation != null && result.products.isNotEmpty) {
        try {
          final batch = await repo.fetchProductStockBatch(
            result.products.map((p) => p.id),
            locationId: defaultLocation,
          );
          for (final product in result.products) {
            stockMap[product.id] = batch[product.id] ?? 0;
          }
        } catch (_) {
          for (final product in result.products) {
            stockMap[product.id] = 0;
          }
        }
      } else {
        // If no location or products, set all to 0
        for (final product in result.products) {
          stockMap[product.id] = 0;
        }
      }

      state = state.copyWith(
        isLoading: false,
        products: [...state.products, ...result.products],
        pagination: result.pagination,
        stockMap: stockMap,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> setFilters({
    String? search,
    String? brandFilter,
    String? sizeFilter,
    num? minPrice,
    num? maxPrice,
    String? stockFilter,
    bool? isActiveFilter,
  }) async {
    // Only update if filters actually changed
    if (state.search == search &&
        state.brandFilter == brandFilter &&
        state.sizeFilter == sizeFilter &&
        state.minPrice == minPrice &&
        state.maxPrice == maxPrice &&
        state.stockFilter == stockFilter &&
        state.isActiveFilter == isActiveFilter) {
      return;
    }

    state = state.copyWith(
      search: search,
      brandFilter: brandFilter,
      sizeFilter: sizeFilter,
      minPrice: minPrice,
      maxPrice: maxPrice,
      stockFilter: stockFilter,
      isActiveFilter: isActiveFilter,
      products: [],
      pagination: null,
      selectedIds: {},
    );
    await refresh();
  }

  void toggleSelection(String productId) {
    final selected = Set<String>.from(state.selectedIds);
    if (selected.contains(productId)) {
      selected.remove(productId);
    } else {
      selected.add(productId);
    }
    state = state.copyWith(selectedIds: selected);
  }

  void selectAll() {
    state = state.copyWith(
      selectedIds: state.products.map((p) => p.id).toSet(),
    );
  }

  void clearSelection() {
    state = state.copyWith(selectedIds: {});
  }

  Future<void> bulkDeactivate() async {
    if (state.selectedIds.isEmpty) return;

    try {
      final repo = ref.read(productsRepositoryProvider);
      for (final id in state.selectedIds) {
        await repo.updateProduct(id, const UpdateProductDto(isActive: false));
      }
      state = state.copyWith(selectedIds: {});
      await refresh();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> createProduct(CreateProductDto payload) async {
    try {
      final repo = ref.read(productsRepositoryProvider);
      await repo.createProduct(payload);
      await refresh();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> updateProduct(String id, UpdateProductDto payload) async {
    try {
      final repo = ref.read(productsRepositoryProvider);
      await repo.updateProduct(id, payload);
      await refresh();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final repo = ref.read(productsRepositoryProvider);
      await repo.deleteProduct(id);
      await refresh();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<String?> _getDefaultLocation() async {
    try {
      final res = await ref.read(dioProvider).get(Endpoints.locationsDefault);
      final data = res.data as Map<String, dynamic>;
      final inner = data['data'];
      if (inner is Map) return inner['id'] as String?;
      return null;
    } catch (_) {
      return null;
    }
  }
}
