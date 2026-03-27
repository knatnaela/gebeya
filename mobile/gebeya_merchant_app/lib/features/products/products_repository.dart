import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/endpoints.dart';
import '../../core/api/api_client.dart';
import '../../core/api/dto/api_response_dto.dart';
import '../../models/product.dart';
import 'dto/product_dto.dart';
import 'dto/product_list_response_dto.dart';
import 'dto/create_product_dto.dart';
import 'dto/update_product_dto.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepository(ref.watch(dioProvider));
});

class ProductsRepository {
  ProductsRepository(this._dio);

  final Dio _dio;

  Future<({List<Product> products, PaginationDto pagination})> fetchProducts({
    String? search,
    String? brand,
    String? size,
    num? minPrice,
    num? maxPrice,
    bool? lowStock,
    bool? inStock,
    bool? outOfStock,
    bool? isActive,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (brand != null && brand.isNotEmpty) query['brand'] = brand;
    if (size != null && size.isNotEmpty) query['size'] = size;
    if (minPrice != null) query['minPrice'] = minPrice.toString();
    if (maxPrice != null) query['maxPrice'] = maxPrice.toString();
    if (lowStock == true) query['lowStock'] = 'true';
    if (inStock == true) query['inStock'] = 'true';
    if (outOfStock == true) query['outOfStock'] = 'true';
    if (isActive != null) query['isActive'] = isActive.toString();

    final res = await _dio.get(Endpoints.products, queryParameters: query);

    // Backend returns: { success: true, data: products[], pagination: {...} }
    final data = res.data as Map<String, dynamic>;
    final productsList = data['data'] as List<dynamic>? ?? [];
    final paginationMap = data['pagination'] as Map<String, dynamic>?;

    final products = productsList
        .map((json) => ProductDto.fromJson(json as Map<String, dynamic>))
        .map((dto) => dto.toDomain())
        .toList();

    final pagination = paginationMap != null
        ? PaginationDto.fromJson(paginationMap)
        : const PaginationDto(page: 1, limit: 20, total: 0, totalPages: 0);

    return (products: products, pagination: pagination);
  }

  Future<List<Product>> fetchLowStockProducts() async {
    final res = await _dio.get(Endpoints.productsLowStock);
    final envelope = ApiResponseDto<List<ProductDto>>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => (json as List<dynamic>)
          .map((e) => ProductDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    final dtos = envelope.data ?? [];
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  Future<Product> fetchProductById(String id) async {
    final res = await _dio.get('${Endpoints.products}/$id');
    final envelope = ApiResponseDto<ProductDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => ProductDto.fromJson(json as Map<String, dynamic>),
    );

    final dto = envelope.data;
    if (dto == null) throw const ProductsRepositoryException('Missing product data.');
    return dto.toDomain();
  }

  Future<Product> createProduct(CreateProductDto payload) async {
    final res = await _dio.post(
      Endpoints.products,
      data: payload.toJson(),
    );
    final envelope = ApiResponseDto<ProductDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => ProductDto.fromJson(json as Map<String, dynamic>),
    );

    final dto = envelope.data;
    if (dto == null) throw const ProductsRepositoryException('Missing product data.');
    return dto.toDomain();
  }

  Future<Product> updateProduct(String id, UpdateProductDto payload) async {
    final res = await _dio.put(
      '${Endpoints.products}/$id',
      data: payload.toJson(),
    );
    final envelope = ApiResponseDto<ProductDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => ProductDto.fromJson(json as Map<String, dynamic>),
    );

    final dto = envelope.data;
    if (dto == null) throw const ProductsRepositoryException('Missing product data.');
    return dto.toDomain();
  }

  Future<void> deleteProduct(String id) async {
    await _dio.delete('${Endpoints.products}/$id');
  }

  Future<num> fetchProductStock(String productId, {String? locationId}) async {
    final query = <String, dynamic>{};
    if (locationId != null) query['locationId'] = locationId;

    final res = await _dio.get(
      Endpoints.inventoryStock(productId),
      queryParameters: query.isEmpty ? null : query,
    );
    final envelope = ApiResponseDto<Map<String, dynamic>>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => json as Map<String, dynamic>,
    );

    final data = envelope.data;
    if (data == null) return 0;
    final stock = data['stock'] ?? data['quantity'];
    if (stock is num) return stock;
    if (stock is int) return stock;
    return 0;
  }

  /// One request for current stock at [locationId] for many products (server batch).
  Future<Map<String, num>> fetchProductStockBatch(
    Iterable<String> productIds, {
    String? locationId,
  }) async {
    final ids = productIds.toSet().toList();
    if (ids.isEmpty) return {};

    final res = await _dio.post(
      Endpoints.inventoryStockBatch,
      data: {
        'productIds': ids,
        if (locationId != null) 'locationId': locationId,
      },
    );
    final envelope = ApiResponseDto<Map<String, dynamic>>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => json as Map<String, dynamic>,
    );

    final data = envelope.data;
    if (data == null) return {};
    final raw = data['stockByProduct'];
    if (raw is! Map) return {};

    final out = <String, num>{};
    for (final e in raw.entries) {
      final v = e.value;
      if (v is num) {
        out[e.key.toString()] = v;
      } else if (v is int) {
        out[e.key.toString()] = v;
      }
    }
    return out;
  }
}

class ProductsRepositoryException implements Exception {
  const ProductsRepositoryException(this.message);
  final String message;

  @override
  String toString() => message;
}
