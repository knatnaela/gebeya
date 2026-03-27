// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_analytics_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalesAnalyticsDto _$SalesAnalyticsDtoFromJson(Map<String, dynamic> json) =>
    SalesAnalyticsDto(
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
              ?.map((e) => TopProductDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TopProductDto>[],
      dailySales:
          (json['dailySales'] as List<dynamic>?)
              ?.map(
                (e) => DailySalesPointDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <DailySalesPointDto>[],
    );

Map<String, dynamic> _$SalesAnalyticsDtoToJson(SalesAnalyticsDto instance) =>
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

TopProductDto _$TopProductDtoFromJson(Map<String, dynamic> json) =>
    TopProductDto(
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      revenue: json['revenue'] as num,
    );

Map<String, dynamic> _$TopProductDtoToJson(TopProductDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity,
      'revenue': instance.revenue,
    };

DailySalesPointDto _$DailySalesPointDtoFromJson(Map<String, dynamic> json) =>
    DailySalesPointDto(
      date: json['date'] as String,
      count: (json['count'] as num).toInt(),
      revenue: json['revenue'] as num,
    );

Map<String, dynamic> _$DailySalesPointDtoToJson(DailySalesPointDto instance) =>
    <String, dynamic>{
      'date': instance.date,
      'count': instance.count,
      'revenue': instance.revenue,
    };
