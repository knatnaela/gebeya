import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/api/dto/api_response_dto.dart';
import '../../models/sale.dart';
import '../products/dto/product_list_response_dto.dart';
import 'dto/create_sale_dto.dart';
import 'dto/sale_dto.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository(ref.watch(dioProvider));
});

class SalesRepository {
  SalesRepository(this._dio);

  final Dio _dio;

  Future<({List<Sale> sales, PaginationDto pagination})> fetchSales({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (startDate != null) {
      query['startDate'] = startDate.toUtc().toIso8601String();
    }
    if (endDate != null) {
      query['endDate'] = endDate.toUtc().toIso8601String();
    }

    final res = await _dio.get(Endpoints.sales, queryParameters: query);

    final data = res.data as Map<String, dynamic>;
    final salesList = data['data'] as List<dynamic>? ?? [];
    final paginationMap = data['pagination'] as Map<String, dynamic>?;

    final sales = salesList
        .map((json) => SaleDto.fromJson(json as Map<String, dynamic>).toDomain())
        .toList();

    final pagination = paginationMap != null
        ? PaginationDto.fromJson(paginationMap)
        : const PaginationDto(page: 1, limit: 20, total: 0, totalPages: 0);

    return (sales: sales, pagination: pagination);
  }

  Future<Sale> fetchSaleById(String id) async {
    final res = await _dio.get(Endpoints.sale(id));
    final envelope = ApiResponseDto<SaleDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => SaleDto.fromJson(json as Map<String, dynamic>),
    );

    final dto = envelope.data;
    if (dto == null) throw const SalesRepositoryException('Missing sale data.');
    return dto.toDomain();
  }

  Future<Sale> createSale(CreateSaleDto payload) async {
    final res = await _dio.post(Endpoints.sales, data: payload.toJson());
    final envelope = ApiResponseDto<SaleDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => SaleDto.fromJson(json as Map<String, dynamic>),
    );

    final dto = envelope.data;
    if (dto == null) throw const SalesRepositoryException('Missing sale data.');
    return dto.toDomain();
  }
}

class SalesRepositoryException implements Exception {
  const SalesRepositoryException(this.message);
  final String message;

  @override
  String toString() => message;
}
