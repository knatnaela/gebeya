// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_product_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateProductDto _$CreateProductDtoFromJson(Map<String, dynamic> json) =>
    CreateProductDto(
      name: json['name'] as String,
      brand: json['brand'] as String?,
      size: json['size'] as String?,
      price: json['price'] as num,
      costPrice: json['costPrice'] as num,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      description: json['description'] as String?,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt(),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$CreateProductDtoToJson(CreateProductDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'brand': instance.brand,
      'size': instance.size,
      'price': instance.price,
      'costPrice': instance.costPrice,
      'sku': instance.sku,
      'barcode': instance.barcode,
      'description': instance.description,
      'lowStockThreshold': instance.lowStockThreshold,
      'imageUrl': instance.imageUrl,
    };
