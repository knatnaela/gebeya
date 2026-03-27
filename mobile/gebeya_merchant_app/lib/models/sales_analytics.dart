import 'package:freezed_annotation/freezed_annotation.dart';

part 'sales_analytics.freezed.dart';
part 'sales_analytics.g.dart';

@freezed
abstract class SalesAnalytics with _$SalesAnalytics {
  const factory SalesAnalytics({
    required int totalSales,
    required num totalRevenue,
    required num totalCostOfGoodsSold,
    required num grossProfit,
    required num totalExpenses,
    required num netProfit,
    required num profitMargin,
    required num averageSaleAmount,
    @Default(<TopProduct>[]) List<TopProduct> topProducts,
    @Default(<DailySalesPoint>[]) List<DailySalesPoint> dailySales,
  }) = _SalesAnalytics;

  factory SalesAnalytics.fromJson(Map<String, dynamic> json) =>
      _$SalesAnalyticsFromJson(json);
}

@freezed
abstract class TopProduct with _$TopProduct {
  const factory TopProduct({
    required String name,
    required int quantity,
    required num revenue,
  }) = _TopProduct;

  factory TopProduct.fromJson(Map<String, dynamic> json) =>
      _$TopProductFromJson(json);
}

@freezed
abstract class DailySalesPoint with _$DailySalesPoint {
  const factory DailySalesPoint({
    required String date, // yyyy-mm-dd
    required int count,
    required num revenue,
  }) = _DailySalesPoint;

  factory DailySalesPoint.fromJson(Map<String, dynamic> json) =>
      _$DailySalesPointFromJson(json);
}

