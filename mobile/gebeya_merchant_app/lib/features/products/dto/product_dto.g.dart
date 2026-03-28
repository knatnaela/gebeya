// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductDto _$ProductDtoFromJson(Map<String, dynamic> json) => ProductDto(
  id: json['id'] as String,
  name: json['name'] as String,
  brand: json['brand'] as String?,
  size: json['size'] as String?,
  measureUnit: $enumDecode(_$ProductMeasureUnitEnumMap, json['measureUnit']),
  price: ProductDto._numFromJson(json['price']),
  costPrice: ProductDto._numFromJson(json['costPrice']),
  sku: json['sku'] as String?,
  barcode: json['barcode'] as String?,
  description: json['description'] as String?,
  lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 5,
  imageUrl: json['imageUrl'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ProductDtoToJson(ProductDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'brand': instance.brand,
      'size': instance.size,
      'measureUnit': _$ProductMeasureUnitEnumMap[instance.measureUnit]!,
      'price': instance.price,
      'costPrice': instance.costPrice,
      'sku': instance.sku,
      'barcode': instance.barcode,
      'description': instance.description,
      'lowStockThreshold': instance.lowStockThreshold,
      'imageUrl': instance.imageUrl,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ProductMeasureUnitEnumMap = {
  ProductMeasureUnit.PCS: 'PCS',
  ProductMeasureUnit.ML: 'ML',
  ProductMeasureUnit.L: 'L',
  ProductMeasureUnit.G: 'G',
  ProductMeasureUnit.KG: 'KG',
  ProductMeasureUnit.IN: 'IN',
  ProductMeasureUnit.CM: 'CM',
  ProductMeasureUnit.MM: 'MM',
  ProductMeasureUnit.M: 'M',
  ProductMeasureUnit.FT: 'FT',
  ProductMeasureUnit.YD: 'YD',
  ProductMeasureUnit.OZ: 'OZ',
  ProductMeasureUnit.LB: 'LB',
  ProductMeasureUnit.GAL: 'GAL',
  ProductMeasureUnit.FL_OZ: 'FL_OZ',
};
