import 'package:json_annotation/json_annotation.dart';

import '../../../models/product.dart';
import '../../../models/product_measure_unit.dart';

part 'product_dto.g.dart';

@JsonSerializable()
class ProductDto {
  const ProductDto({
    required this.id,
    required this.name,
    this.brand,
    this.size,
    required this.measureUnit,
    required this.price,
    required this.costPrice,
    this.sku,
    this.barcode,
    this.description,
    this.lowStockThreshold = 5,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? brand;
  final String? size;
  final ProductMeasureUnit measureUnit;
  @JsonKey(fromJson: _numFromJson)
  final num price;
  @JsonKey(fromJson: _numFromJson)
  final num costPrice;
  final String? sku;
  final String? barcode;
  final String? description;
  final int lowStockThreshold;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  static num _numFromJson(dynamic value) {
    if (value is num) return value;
    if (value is String) {
      final parsed = num.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw FormatException('Cannot convert $value to num');
  }

  factory ProductDto.fromJson(Map<String, dynamic> json) =>
      _$ProductDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDtoToJson(this);

  Product toDomain() {
    return Product(
      id: id,
      name: name,
      brand: brand,
      size: size,
      measureUnit: measureUnit,
      price: price,
      costPrice: costPrice,
      sku: sku,
      barcode: barcode,
      description: description,
      lowStockThreshold: lowStockThreshold,
      imageUrl: imageUrl,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
