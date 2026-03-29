// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleUserDto _$SaleUserDtoFromJson(Map<String, dynamic> json) => SaleUserDto(
  id: json['id'] as String,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  email: json['email'] as String?,
);

SaleProductEmbeddedDto _$SaleProductEmbeddedDtoFromJson(
  Map<String, dynamic> json,
) => SaleProductEmbeddedDto(
  id: json['id'] as String,
  name: json['name'] as String,
  brand: json['brand'] as String?,
  sku: json['sku'] as String?,
  size: json['size'] as String?,
  costPrice: _numFromJson(json['costPrice']),
);

SaleItemDto _$SaleItemDtoFromJson(Map<String, dynamic> json) => SaleItemDto(
  id: json['id'] as String,
  saleId: json['saleId'] as String,
  productId: json['productId'] as String,
  quantity: (json['quantity'] as num).toInt(),
  unitPrice: _numFromJson(json['unitPrice']),
  totalPrice: _numFromJson(json['totalPrice']),
  defaultPrice: _numFromJson(json['defaultPrice']),
  products: json['products'] == null
      ? null
      : SaleProductEmbeddedDto.fromJson(
          json['products'] as Map<String, dynamic>,
        ),
);

MerchantEmbeddedDto _$MerchantEmbeddedDtoFromJson(Map<String, dynamic> json) =>
    MerchantEmbeddedDto(name: json['name'] as String?);

SaleLocationEmbeddedDto _$SaleLocationEmbeddedDtoFromJson(
  Map<String, dynamic> json,
) => SaleLocationEmbeddedDto(
  id: json['id'] as String?,
  name: json['name'] as String?,
);

SaleDto _$SaleDtoFromJson(Map<String, dynamic> json) => SaleDto(
  id: json['id'] as String,
  merchantId: json['merchantId'] as String,
  userId: json['userId'] as String,
  totalAmount: _numFromJson(json['totalAmount']),
  platformFee: _optionalNumFromJson(json['platformFee']),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  saleDate: DateTime.parse(json['saleDate'] as String),
  customerName: json['customerName'] as String?,
  customerPhoneCountryIso: json['customerPhoneCountryIso'] as String?,
  customerPhoneDialCode: json['customerPhoneDialCode'] as String?,
  customerPhoneNationalNumber: json['customerPhoneNationalNumber'] as String?,
  customerPhone: json['customerPhone'] as String?,
  saleItems: (json['sale_items'] as List<dynamic>?)
      ?.map((e) => SaleItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  users: json['users'] == null
      ? null
      : SaleUserDto.fromJson(json['users'] as Map<String, dynamic>),
  merchants: json['merchants'] == null
      ? null
      : MerchantEmbeddedDto.fromJson(json['merchants'] as Map<String, dynamic>),
  locations: json['locations'] == null
      ? null
      : SaleLocationEmbeddedDto.fromJson(
          json['locations'] as Map<String, dynamic>,
        ),
  status: json['status'] as String?,
  voidedAt: json['voidedAt'] == null
      ? null
      : DateTime.parse(json['voidedAt'] as String),
  voidReason: json['voidReason'] as String?,
  netIncome: _numFromJson(json['netIncome']),
  profitMargin: _numFromJson(json['profitMargin']),
  costOfGoodsSold: _numFromJson(json['costOfGoodsSold']),
);
