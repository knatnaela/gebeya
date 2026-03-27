// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SalesAnalytics _$SalesAnalyticsFromJson(Map<String, dynamic> json) =>
    _SalesAnalytics(
      totalSales: (json['totalSales'] as num).toInt(),
      totalRevenue: json['totalRevenue'] as num,
      totalCostOfGoodsSold: json['totalCostOfGoodsSold'] as num,
      grossProfit: json['grossProfit'] as num,
      totalExpenses: json['totalExpenses'] as num,
      netProfit: json['netProfit'] as num,
      profitMargin: json['profitMargin'] as num,
      averageSaleAmount: json['averageSaleAmount'] as num,
      topProducts:
          (json['topProducts'] as List<dynamic>?)
              ?.map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TopProduct>[],
      dailySales:
          (json['dailySales'] as List<dynamic>?)
              ?.map((e) => DailySalesPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <DailySalesPoint>[],
    );

Map<String, dynamic> _$SalesAnalyticsToJson(_SalesAnalytics instance) =>
    <String, dynamic>{
      'totalSales': instance.totalSales,
      'totalRevenue': instance.totalRevenue,
      'totalCostOfGoodsSold': instance.totalCostOfGoodsSold,
      'grossProfit': instance.grossProfit,
      'totalExpenses': instance.totalExpenses,
      'netProfit': instance.netProfit,
      'profitMargin': instance.profitMargin,
      'averageSaleAmount': instance.averageSaleAmount,
      'topProducts': instance.topProducts,
      'dailySales': instance.dailySales,
    };

_TopProduct _$TopProductFromJson(Map<String, dynamic> json) => _TopProduct(
  name: json['name'] as String,
  quantity: (json['quantity'] as num).toInt(),
  revenue: json['revenue'] as num,
);

Map<String, dynamic> _$TopProductToJson(_TopProduct instance) =>
    <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity,
      'revenue': instance.revenue,
    };

_DailySalesPoint _$DailySalesPointFromJson(Map<String, dynamic> json) =>
    _DailySalesPoint(
      date: json['date'] as String,
      count: (json['count'] as num).toInt(),
      revenue: json['revenue'] as num,
    );

Map<String, dynamic> _$DailySalesPointToJson(_DailySalesPoint instance) =>
    <String, dynamic>{
      'date': instance.date,
      'count': instance.count,
      'revenue': instance.revenue,
    };
