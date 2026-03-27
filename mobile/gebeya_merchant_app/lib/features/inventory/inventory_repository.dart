import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/endpoints.dart';
import '../../core/api/api_client.dart';
import '../../core/api/dto/api_response_dto.dart';
import '../../models/inventory_summary.dart';
import '../../models/inventory_transaction.dart';
import '../../models/inventory_entry.dart';
import '../../models/location.dart';
import '../../models/product.dart';
import '../dashboard/dto/inventory_summary_dto.dart';
import '../products/dto/product_dto.dart';
import '../products/dto/product_list_response_dto.dart';
import 'dto/inventory_transaction_dto.dart';
import 'dto/create_transaction_dto.dart';
import 'dto/inventory_entry_dto.dart';
import 'dto/add_stock_dto.dart';
import 'dto/transfer_stock_dto.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(ref.watch(dioProvider));
});

class InventoryRepository {
  InventoryRepository(this._dio);

  final Dio _dio;

  Future<InventorySummary> fetchInventorySummary() async {
    final res = await _dio.get(Endpoints.inventorySummary);
    final envelope = ApiResponseDto<InventorySummaryDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => InventorySummaryDto.fromJson(json as Map<String, dynamic>),
    );

    final dto = envelope.data;
    if (dto == null) throw const InventoryRepositoryException('Missing inventory summary data.');
    return dto.toDomain();
  }

  Future<({List<InventoryTransaction> transactions, PaginationDto pagination})> fetchTransactions({
    String? productId,
    InventoryTransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (productId != null && productId.isNotEmpty) query['productId'] = productId;
    if (type != null) query['type'] = _typeToBackendString(type);
    if (startDate != null) query['startDate'] = startDate.toIso8601String();
    if (endDate != null) query['endDate'] = endDate.toIso8601String();

    final res = await _dio.get(Endpoints.inventoryTransactions, queryParameters: query);

    // Backend returns: { success: true, data: transactions[], pagination: {...} }
    final data = res.data as Map<String, dynamic>;
    final transactionsList = data['data'] as List<dynamic>? ?? [];
    final paginationMap = data['pagination'] as Map<String, dynamic>?;

    final transactions = transactionsList
        .map((json) => InventoryTransactionDto.fromJson(json as Map<String, dynamic>))
        .map((dto) => dto.toDomain())
        .toList();

    final pagination = paginationMap != null
        ? PaginationDto.fromJson(paginationMap)
        : const PaginationDto(page: 1, limit: 20, total: 0, totalPages: 0);

    return (transactions: transactions, pagination: pagination);
  }

  Future<InventoryTransaction> createTransaction(CreateTransactionDto payload) async {
    final res = await _dio.post(Endpoints.inventoryTransactions, data: payload.toJson());
    final envelope = ApiResponseDto<InventoryTransactionDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => InventoryTransactionDto.fromJson(json as Map<String, dynamic>),
    );

    final dto = envelope.data;
    if (dto == null) throw const InventoryRepositoryException('Missing transaction data.');
    return dto.toDomain();
  }

  Future<List<Product>> fetchProducts({bool? isActive, String? search}) async {
    final query = <String, dynamic>{};
    if (isActive != null) query['isActive'] = isActive.toString();
    if (search != null && search.isNotEmpty) query['search'] = search;

    final res = await _dio.get(Endpoints.products, queryParameters: query.isEmpty ? null : query);
    final data = res.data as Map<String, dynamic>;
    final productsList = data['data'] as List<dynamic>? ?? [];

    return productsList
        .map((json) => ProductDto.fromJson(json as Map<String, dynamic>))
        .map((dto) => dto.toDomain())
        .toList();
  }

  Future<List<Location>> fetchLocations() async {
    final res = await _dio.get(Endpoints.locations);
    final envelope = ApiResponseDto<List<LocationDto>>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => (json as List<dynamic>).map((e) => LocationDto.fromJson(e as Map<String, dynamic>)).toList(),
    );

    final dtos = envelope.data ?? [];
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  Future<({List<InventoryEntry> entries, PaginationDto pagination})> fetchEntries({
    String? productId,
    String? locationId,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (productId != null && productId.isNotEmpty) query['productId'] = productId;
    if (locationId != null && locationId.isNotEmpty) query['locationId'] = locationId;

    final res = await _dio.get(Endpoints.inventoryEntries, queryParameters: query);

    final data = res.data as Map<String, dynamic>;
    final entriesList = data['data'] as List<dynamic>? ?? [];
    final paginationMap = data['pagination'] as Map<String, dynamic>?;

    final entries = entriesList
        .map((json) => InventoryEntryDto.fromJson(json as Map<String, dynamic>))
        .map((dto) => dto.toDomain())
        .toList();

    final pagination = paginationMap != null
        ? PaginationDto.fromJson(paginationMap)
        : const PaginationDto(page: 1, limit: 20, total: 0, totalPages: 0);

    return (entries: entries, pagination: pagination);
  }

  Future<InventoryEntry> addStock(AddStockDto payload) async {
    final res = await _dio.post(Endpoints.addStock, data: payload.toJson());
    final envelope = ApiResponseDto<InventoryEntryDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => InventoryEntryDto.fromJson(json as Map<String, dynamic>),
    );

    final dto = envelope.data;
    if (dto == null) throw const InventoryRepositoryException('Missing inventory entry data.');
    return dto.toDomain();
  }

  Future<void> transferStock(TransferStockDto payload) async {
    final res = await _dio.post(Endpoints.transferStock, data: payload.toJson());
    // Response is just { success: true, data: {...}, message: "..." }
    // We don't need to parse the response for transfer
    if (res.data['success'] != true) {
      throw InventoryRepositoryException(res.data['error'] ?? 'Failed to transfer stock');
    }
  }

  Future<Location> fetchDefaultLocation() async {
    final res = await _dio.get(Endpoints.locationsDefault);
    final envelope = ApiResponseDto<LocationDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => LocationDto.fromJson(json as Map<String, dynamic>),
    );

    final dto = envelope.data;
    if (dto == null) throw const InventoryRepositoryException('Missing default location data.');
    return dto.toDomain();
  }

  String _typeToBackendString(InventoryTransactionType type) {
    switch (type) {
      case InventoryTransactionType.sale:
        return 'SALE';
      case InventoryTransactionType.adjustment:
        return 'ADJUSTMENT';
      case InventoryTransactionType.restock:
        return 'RESTOCK';
      case InventoryTransactionType.return_:
        return 'RETURN';
      case InventoryTransactionType.transferIn:
        return 'TRANSFER_IN';
      case InventoryTransactionType.transferOut:
        return 'TRANSFER_OUT';
      case InventoryTransactionType.stockIn:
        return 'STOCK_IN';
    }
  }
}

class InventoryRepositoryException implements Exception {
  const InventoryRepositoryException(this.message);
  final String message;

  @override
  String toString() => message;
}
