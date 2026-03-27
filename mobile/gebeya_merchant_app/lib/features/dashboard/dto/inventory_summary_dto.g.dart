// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventorySummaryDto _$InventorySummaryDtoFromJson(
  Map<String, dynamic> json,
) => InventorySummaryDto(
  totalProducts: (json['totalProducts'] as num).toInt(),
  totalStockValue: InventorySummaryDto._numFromJson(json['totalStockValue']),
  totalStockQuantity: InventorySummaryDto._numFromJson(
    json['totalStockQuantity'],
  ),
  lowStockCount: (json['lowStockCount'] as num).toInt(),
  outOfStockCount: (json['outOfStockCount'] as num).toInt(),
  lowStockProducts:
      (json['lowStockProducts'] as List<dynamic>?)
          ?.map((e) => LowStockProductDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <LowStockProductDto>[],
  outOfStockProducts:
      (json['outOfStockProducts'] as List<dynamic>?)
          ?.map((e) => OutOfStockProductDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <OutOfStockProductDto>[],
);

Map<String, dynamic> _$InventorySummaryDtoToJson(
  InventorySummaryDto instance,
) => <String, dynamic>{
  'totalProducts': instance.totalProducts,
  'totalStockValue': instance.totalStockValue,
  'totalStockQuantity': instance.totalStockQuantity,
  'lowStockCount': instance.lowStockCount,
  'outOfStockCount': instance.outOfStockCount,
  'lowStockProducts': instance.lowStockProducts,
  'outOfStockProducts': instance.outOfStockProducts,
};

LowStockProductDto _$LowStockProductDtoFromJson(Map<String, dynamic> json) =>
    LowStockProductDto(
      id: json['id'] as String,
      name: json['name'] as String,
      stockQuantity: LowStockProductDto._numFromJson(json['stockQuantity']),
      threshold: LowStockProductDto._numFromJson(json['threshold']),
    );

Map<String, dynamic> _$LowStockProductDtoToJson(LowStockProductDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'stockQuantity': instance.stockQuantity,
      'threshold': instance.threshold,
    };

OutOfStockProductDto _$OutOfStockProductDtoFromJson(
  Map<String, dynamic> json,
) => OutOfStockProductDto(
  id: json['id'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$OutOfStockProductDtoToJson(
  OutOfStockProductDto instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};
