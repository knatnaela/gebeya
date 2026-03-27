import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/endpoints.dart';
import '../../core/api/api_client.dart';
import '../../core/api/dto/api_response_dto.dart';
import '../../models/inventory_summary.dart';
import '../../models/sales_analytics.dart';
import 'dto/inventory_summary_dto.dart';
import 'dto/sales_analytics_dto.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(dioProvider));
});

class DashboardRepository {
  DashboardRepository(this._dio);

  final Dio _dio;

  Future<InventorySummary> fetchInventorySummary() async {
    final res = await _dio.get(Endpoints.inventorySummary);
    final envelope = ApiResponseDto<InventorySummaryDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => InventorySummaryDto.fromJson(json as Map<String, dynamic>),
    );

    final dto = envelope.data;
    if (dto == null) throw const ApiException('Missing inventory summary data.');
    return dto.toDomain();
  }

  Future<SalesAnalytics> fetchSalesAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = <String, dynamic>{};
    if (startDate != null) query['startDate'] = startDate.toIso8601String();
    if (endDate != null) query['endDate'] = endDate.toIso8601String();

    final res = await _dio.get(
      Endpoints.salesAnalytics,
      queryParameters: query.isEmpty ? null : query,
    );
    final envelope = ApiResponseDto<SalesAnalyticsDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => SalesAnalyticsDto.fromJson(json as Map<String, dynamic>),
    );

    final dto = envelope.data;
    if (dto == null) throw const ApiException('Missing sales analytics data.');
    return dto.toDomain();
  }
}

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

