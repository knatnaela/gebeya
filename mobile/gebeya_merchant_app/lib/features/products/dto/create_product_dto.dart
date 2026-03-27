import 'package:json_annotation/json_annotation.dart';

part 'create_product_dto.g.dart';

@JsonSerializable()
class CreateProductDto {
  const CreateProductDto({
    required this.name,
    this.brand,
    this.size,
    required this.price,
    required this.costPrice,
    this.sku,
    this.barcode,
    this.description,
    this.lowStockThreshold,
    this.imageUrl,
  });

  final String name;
  final String? brand;
  final String? size;
  final num price;
  final num costPrice;
  final String? sku;
  final String? barcode;
  final String? description;
  final int? lowStockThreshold;
  final String? imageUrl;

  factory CreateProductDto.fromJson(Map<String, dynamic> json) =>
      _$CreateProductDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateProductDtoToJson(this);
}
