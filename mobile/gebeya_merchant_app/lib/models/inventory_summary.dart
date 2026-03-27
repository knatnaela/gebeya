import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_summary.freezed.dart';
part 'inventory_summary.g.dart';

@freezed
abstract class InventorySummary with _$InventorySummary {
  const factory InventorySummary({
    required int totalProducts,
    required num totalStockValue,
    required num totalStockQuantity,
    required int lowStockCount,
    required int outOfStockCount,
    @Default(<LowStockProduct>[]) List<LowStockProduct> lowStockProducts,
    @Default(<OutOfStockProduct>[]) List<OutOfStockProduct> outOfStockProducts,
  }) = _InventorySummary;

  factory InventorySummary.fromJson(Map<String, dynamic> json) =>
      _$InventorySummaryFromJson(json);
}

@freezed
abstract class LowStockProduct with _$LowStockProduct {
  const factory LowStockProduct({
    required String id,
    required String name,
    required num stockQuantity,
    required num threshold,
  }) = _LowStockProduct;

  factory LowStockProduct.fromJson(Map<String, dynamic> json) =>
      _$LowStockProductFromJson(json);
}

@freezed
abstract class OutOfStockProduct with _$OutOfStockProduct {
  const factory OutOfStockProduct({
    required String id,
    required String name,
  }) = _OutOfStockProduct;

  factory OutOfStockProduct.fromJson(Map<String, dynamic> json) =>
      _$OutOfStockProductFromJson(json);
}

