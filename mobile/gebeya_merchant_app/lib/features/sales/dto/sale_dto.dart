import 'package:json_annotation/json_annotation.dart';

import '../../../models/sale.dart';

part 'sale_dto.g.dart';

num _numFromJson(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value;
  if (value is String) {
    final parsed = num.tryParse(value);
    if (parsed != null) return parsed;
  }
  return 0;
}

num? _optionalNumFromJson(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

@JsonSerializable(createToJson: false)
class SaleUserDto {
  const SaleUserDto({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;

  factory SaleUserDto.fromJson(Map<String, dynamic> json) => _$SaleUserDtoFromJson(json);

  SaleSeller toSeller() => SaleSeller(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
}

@JsonSerializable(createToJson: false)
class SaleProductEmbeddedDto {
  const SaleProductEmbeddedDto({
    required this.id,
    required this.name,
    this.brand,
    this.sku,
    this.size,
    this.costPrice,
  });

  final String id;
  final String name;
  final String? brand;
  final String? sku;
  final String? size;
  @JsonKey(fromJson: _numFromJson)
  final num? costPrice;

  factory SaleProductEmbeddedDto.fromJson(Map<String, dynamic> json) =>
      _$SaleProductEmbeddedDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class SaleItemDto {
  const SaleItemDto({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.defaultPrice,
    this.products,
  });

  final String id;
  final String saleId;
  final String productId;
  final int quantity;
  @JsonKey(fromJson: _numFromJson)
  final num unitPrice;
  @JsonKey(fromJson: _numFromJson)
  final num totalPrice;
  @JsonKey(fromJson: _numFromJson)
  final num defaultPrice;
  final SaleProductEmbeddedDto? products;

  factory SaleItemDto.fromJson(Map<String, dynamic> json) => _$SaleItemDtoFromJson(json);

  SaleLineItem toDomain() {
    final p = products;
    return SaleLineItem(
      id: id,
      productId: productId,
      productName: p?.name ?? 'Product',
      brand: p?.brand,
      sku: p?.sku,
      size: p?.size,
      quantity: quantity,
      unitPrice: unitPrice,
      defaultPrice: defaultPrice,
      totalPrice: totalPrice,
      costPrice: p?.costPrice ?? 0,
    );
  }
}

@JsonSerializable(createToJson: false)
class MerchantEmbeddedDto {
  const MerchantEmbeddedDto({this.name});

  final String? name;

  factory MerchantEmbeddedDto.fromJson(Map<String, dynamic> json) => _$MerchantEmbeddedDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class SaleDto {
  const SaleDto({
    required this.id,
    required this.merchantId,
    required this.userId,
    required this.totalAmount,
    this.platformFee,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.saleDate,
    this.customerName,
    this.customerPhone,
    this.saleItems,
    this.users,
    this.merchants,
    this.netIncome,
    this.profitMargin,
    this.costOfGoodsSold,
  });

  final String id;
  final String merchantId;
  final String userId;
  @JsonKey(fromJson: _numFromJson)
  final num totalAmount;
  @JsonKey(fromJson: _optionalNumFromJson)
  final num? platformFee;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime saleDate;
  final String? customerName;
  final String? customerPhone;
  @JsonKey(name: 'sale_items')
  final List<SaleItemDto>? saleItems;
  final SaleUserDto? users;
  @JsonKey(name: 'merchants')
  final MerchantEmbeddedDto? merchants;
  @JsonKey(fromJson: _numFromJson)
  final num? netIncome;
  @JsonKey(fromJson: _numFromJson)
  final num? profitMargin;
  @JsonKey(fromJson: _numFromJson)
  final num? costOfGoodsSold;

  factory SaleDto.fromJson(Map<String, dynamic> json) => _$SaleDtoFromJson(json);

  Sale toDomain() {
    final items = saleItems ?? const <SaleItemDto>[];
    return Sale(
      id: id,
      saleDate: saleDate,
      createdAt: createdAt,
      totalAmount: totalAmount,
      platformFee: platformFee,
      customerName: customerName,
      customerPhone: customerPhone,
      notes: notes,
      netIncome: netIncome ?? 0,
      profitMargin: profitMargin ?? 0,
      costOfGoodsSold: costOfGoodsSold ?? 0,
      items: items.map((e) => e.toDomain()).toList(),
      seller: users?.toSeller(),
      merchantName: merchants?.name,
    );
  }
}
