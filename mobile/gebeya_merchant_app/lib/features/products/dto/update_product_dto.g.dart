// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_product_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProductDto _$UpdateProductDtoFromJson(Map<String, dynamic> json) =>
    UpdateProductDto(
      name: json['name'] as String?,
      brand: json['brand'] as String?,
      size: json['size'] as String?,
      price: json['price'] as num?,
      costPrice: json['costPrice'] as num?,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      description: json['description'] as String?,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt(),
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$UpdateProductDtoToJson(UpdateProductDto instance) =>
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
      'isActive': instance.isActive,
    };
