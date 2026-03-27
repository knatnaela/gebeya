import 'package:json_annotation/json_annotation.dart';

import '../../../models/sales_analytics.dart';

part 'sales_analytics_dto.g.dart';

@JsonSerializable()
class SalesAnalyticsDto {
  const SalesAnalyticsDto({
    required this.totalSales,
    required this.totalRevenue,
    required this.totalCostOfGoodsSold,
    required this.grossProfit,
    required this.totalExpenses,
    required this.netProfit,
    required this.profitMargin,
    required this.averageSaleAmount,
    this.topProducts = const <TopProductDto>[],
    this.dailySales = const <DailySalesPointDto>[],
  });

  final int totalSales;
  final num totalRevenue;
  final num totalCostOfGoodsSold;
  final num grossProfit;
  final num totalExpenses;
  final num netProfit;
  final num profitMargin;
  final num averageSaleAmount;
  final List<TopProductDto> topProducts;
  final List<DailySalesPointDto> dailySales;

  factory SalesAnalyticsDto.fromJson(Map<String, dynamic> json) =>
      _$SalesAnalyticsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SalesAnalyticsDtoToJson(this);

  SalesAnalytics toDomain() => SalesAnalytics(
        totalSales: totalSales,
        totalRevenue: totalRevenue,
        totalCostOfGoodsSold: totalCostOfGoodsSold,
        grossProfit: grossProfit,
        totalExpenses: totalExpenses,
        netProfit: netProfit,
        profitMargin: profitMargin,
        averageSaleAmount: averageSaleAmount,
        topProducts: topProducts.map((e) => e.toDomain()).toList(),
        dailySales: dailySales.map((e) => e.toDomain()).toList(),
      );
}

@JsonSerializable()
class TopProductDto {
  const TopProductDto({
    required this.name,
    required this.quantity,
    required this.revenue,
  });

  final String name;
  final int quantity;
  final num revenue;

  factory TopProductDto.fromJson(Map<String, dynamic> json) =>
      _$TopProductDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TopProductDtoToJson(this);

  TopProduct toDomain() => TopProduct(name: name, quantity: quantity, revenue: revenue);
}

@JsonSerializable()
class DailySalesPointDto {
  const DailySalesPointDto({
    required this.date,
    required this.count,
    required this.revenue,
  });

  final String date;
  final int count;
  final num revenue;

  factory DailySalesPointDto.fromJson(Map<String, dynamic> json) =>
      _$DailySalesPointDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DailySalesPointDtoToJson(this);

  DailySalesPoint toDomain() =>
      DailySalesPoint(date: date, count: count, revenue: revenue);
}

