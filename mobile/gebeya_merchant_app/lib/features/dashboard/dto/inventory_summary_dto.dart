import 'package:json_annotation/json_annotation.dart';

import '../../../models/inventory_summary.dart';

part 'inventory_summary_dto.g.dart';

@JsonSerializable()
class InventorySummaryDto {
  const InventorySummaryDto({
    required this.totalProducts,
    required this.totalStockValue,
    required this.totalStockQuantity,
    required this.lowStockCount,
    required this.outOfStockCount,
    this.lowStockProducts = const <LowStockProductDto>[],
    this.outOfStockProducts = const <OutOfStockProductDto>[],
  });

  final int totalProducts;
  
  @JsonKey(fromJson: _numFromJson)
  final num totalStockValue;
  
  @JsonKey(fromJson: _numFromJson)
  final num totalStockQuantity;
  
  final int lowStockCount;
  final int outOfStockCount;
  final List<LowStockProductDto> lowStockProducts;
  final List<OutOfStockProductDto> outOfStockProducts;

  static num _numFromJson(dynamic value) {
    if (value is num) return value;
    if (value is String) {
      final parsed = num.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw FormatException('Cannot convert $value to num');
  }

  factory InventorySummaryDto.fromJson(Map<String, dynamic> json) =>
      _$InventorySummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$InventorySummaryDtoToJson(this);

  InventorySummary toDomain() {
    return InventorySummary(
      totalProducts: totalProducts,
      totalStockValue: totalStockValue,
      totalStockQuantity: totalStockQuantity,
      lowStockCount: lowStockCount,
      outOfStockCount: outOfStockCount,
      lowStockProducts: lowStockProducts.map((e) => e.toDomain()).toList(),
      outOfStockProducts: outOfStockProducts.map((e) => e.toDomain()).toList(),
    );
  }
}

@JsonSerializable()
class LowStockProductDto {
  const LowStockProductDto({
    required this.id,
    required this.name,
    required this.stockQuantity,
    required this.threshold,
  });

  final String id;
  final String name;
  
  @JsonKey(fromJson: _numFromJson)
  final num stockQuantity;
  
  @JsonKey(fromJson: _numFromJson)
  final num threshold;

  static num _numFromJson(dynamic value) {
    if (value is num) return value;
    if (value is String) {
      final parsed = num.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw FormatException('Cannot convert $value to num');
  }

  factory LowStockProductDto.fromJson(Map<String, dynamic> json) =>
      _$LowStockProductDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LowStockProductDtoToJson(this);

  LowStockProduct toDomain() => LowStockProduct(
        id: id,
        name: name,
        stockQuantity: stockQuantity,
        threshold: threshold,
      );
}

@JsonSerializable()
class OutOfStockProductDto {
  const OutOfStockProductDto({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory OutOfStockProductDto.fromJson(Map<String, dynamic> json) =>
      _$OutOfStockProductDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OutOfStockProductDtoToJson(this);

  OutOfStockProduct toDomain() => OutOfStockProduct(id: id, name: name);
}

