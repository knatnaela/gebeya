import 'package:json_annotation/json_annotation.dart';

part 'update_product_dto.g.dart';

@JsonSerializable()
class UpdateProductDto {
  const UpdateProductDto({
    this.name,
    this.brand,
    this.size,
    this.price,
    this.costPrice,
    this.sku,
    this.barcode,
    this.description,
    this.lowStockThreshold,
    this.imageUrl,
    this.isActive,
  });

  final String? name;
  final String? brand;
  final String? size;
  final num? price;
  final num? costPrice;
  final String? sku;
  final String? barcode;
  final String? description;
  final int? lowStockThreshold;
  final String? imageUrl;
  final bool? isActive;

  factory UpdateProductDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateProductDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProductDtoToJson(this);
}
