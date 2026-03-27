// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InventorySummary _$InventorySummaryFromJson(Map<String, dynamic> json) =>
    _InventorySummary(
      totalProducts: (json['totalProducts'] as num).toInt(),
      totalStockValue: json['totalStockValue'] as num,
      totalStockQuantity: json['totalStockQuantity'] as num,
      lowStockCount: (json['lowStockCount'] as num).toInt(),
      outOfStockCount: (json['outOfStockCount'] as num).toInt(),
      lowStockProducts:
          (json['lowStockProducts'] as List<dynamic>?)
              ?.map((e) => LowStockProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <LowStockProduct>[],
      outOfStockProducts:
          (json['outOfStockProducts'] as List<dynamic>?)
              ?.map(
                (e) => OutOfStockProduct.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <OutOfStockProduct>[],
    );

Map<String, dynamic> _$InventorySummaryToJson(_InventorySummary instance) =>
    <String, dynamic>{
      'totalProducts': instance.totalProducts,
      'totalStockValue': instance.totalStockValue,
      'totalStockQuantity': instance.totalStockQuantity,
      'lowStockCount': instance.lowStockCount,
      'outOfStockCount': instance.outOfStockCount,
      'lowStockProducts': instance.lowStockProducts,
      'outOfStockProducts': instance.outOfStockProducts,
    };

_LowStockProduct _$LowStockProductFromJson(Map<String, dynamic> json) =>
    _LowStockProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      stockQuantity: json['stockQuantity'] as num,
      threshold: json['threshold'] as num,
    );

Map<String, dynamic> _$LowStockProductToJson(_LowStockProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'stockQuantity': instance.stockQuantity,
      'threshold': instance.threshold,
    };

_OutOfStockProduct _$OutOfStockProductFromJson(Map<String, dynamic> json) =>
    _OutOfStockProduct(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$OutOfStockProductToJson(_OutOfStockProduct instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
