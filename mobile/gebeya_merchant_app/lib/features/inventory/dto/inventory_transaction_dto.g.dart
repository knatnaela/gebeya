// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_transaction_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryTransactionDto _$InventoryTransactionDtoFromJson(
  Map<String, dynamic> json,
) => InventoryTransactionDto(
  id: json['id'] as String,
  productId: json['productId'] as String,
  locationId: json['locationId'] as String,
  userId: json['userId'] as String,
  type: InventoryTransactionDto._typeFromJson(json['type'] as String),
  quantity: (json['quantity'] as num).toInt(),
  reason: json['reason'] as String?,
  referenceId: json['referenceId'] as String?,
  referenceType: json['referenceType'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  products: json['products'] == null
      ? null
      : TransactionProductDto.fromJson(
          json['products'] as Map<String, dynamic>,
        ),
  locations: json['locations'] == null
      ? null
      : TransactionLocationDto.fromJson(
          json['locations'] as Map<String, dynamic>,
        ),
  users: json['users'] == null
      ? null
      : TransactionUserDto.fromJson(json['users'] as Map<String, dynamic>),
);

Map<String, dynamic> _$InventoryTransactionDtoToJson(
  InventoryTransactionDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'locationId': instance.locationId,
  'userId': instance.userId,
  'type': _$InventoryTransactionTypeEnumMap[instance.type]!,
  'quantity': instance.quantity,
  'reason': instance.reason,
  'referenceId': instance.referenceId,
  'referenceType': instance.referenceType,
  'createdAt': instance.createdAt.toIso8601String(),
  'products': instance.products,
  'locations': instance.locations,
  'users': instance.users,
};

const _$InventoryTransactionTypeEnumMap = {
  InventoryTransactionType.sale: 'sale',
  InventoryTransactionType.adjustment: 'adjustment',
  InventoryTransactionType.restock: 'restock',
  InventoryTransactionType.return_: 'return_',
  InventoryTransactionType.transferIn: 'transferIn',
  InventoryTransactionType.transferOut: 'transferOut',
  InventoryTransactionType.stockIn: 'stockIn',
};

TransactionProductDto _$TransactionProductDtoFromJson(
  Map<String, dynamic> json,
) => TransactionProductDto(
  id: json['id'] as String,
  name: json['name'] as String,
  brand: json['brand'] as String?,
  sku: json['sku'] as String?,
);

Map<String, dynamic> _$TransactionProductDtoToJson(
  TransactionProductDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'brand': instance.brand,
  'sku': instance.sku,
};

TransactionLocationDto _$TransactionLocationDtoFromJson(
  Map<String, dynamic> json,
) => TransactionLocationDto(
  id: json['id'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$TransactionLocationDtoToJson(
  TransactionLocationDto instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};

LocationDto _$LocationDtoFromJson(Map<String, dynamic> json) => LocationDto(
  id: json['id'] as String,
  merchantId: json['merchantId'] as String,
  name: json['name'] as String,
  address: json['address'] as String?,
  phoneCountryIso: json['phoneCountryIso'] as String?,
  phoneDialCode: json['phoneDialCode'] as String?,
  phoneNationalNumber: json['phoneNationalNumber'] as String?,
  phone: json['phone'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  isDefault: json['isDefault'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$LocationDtoToJson(LocationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'merchantId': instance.merchantId,
      'name': instance.name,
      'address': instance.address,
      'phoneCountryIso': instance.phoneCountryIso,
      'phoneDialCode': instance.phoneDialCode,
      'phoneNationalNumber': instance.phoneNationalNumber,
      'phone': instance.phone,
      'isActive': instance.isActive,
      'isDefault': instance.isDefault,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

TransactionUserDto _$TransactionUserDtoFromJson(Map<String, dynamic> json) =>
    TransactionUserDto(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$TransactionUserDtoToJson(TransactionUserDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
    };
