// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InventoryTransaction _$InventoryTransactionFromJson(
  Map<String, dynamic> json,
) => _InventoryTransaction(
  id: json['id'] as String,
  productId: json['productId'] as String,
  locationId: json['locationId'] as String,
  userId: json['userId'] as String,
  type: $enumDecode(_$InventoryTransactionTypeEnumMap, json['type']),
  quantity: (json['quantity'] as num).toInt(),
  reason: json['reason'] as String?,
  referenceId: json['referenceId'] as String?,
  referenceType: json['referenceType'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  product: json['product'] == null
      ? null
      : TransactionProduct.fromJson(json['product'] as Map<String, dynamic>),
  location: json['location'] == null
      ? null
      : Location.fromJson(json['location'] as Map<String, dynamic>),
  user: json['user'] == null
      ? null
      : TransactionUser.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$InventoryTransactionToJson(
  _InventoryTransaction instance,
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
  'product': instance.product,
  'location': instance.location,
  'user': instance.user,
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

_TransactionProduct _$TransactionProductFromJson(Map<String, dynamic> json) =>
    _TransactionProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      sku: json['sku'] as String?,
    );

Map<String, dynamic> _$TransactionProductToJson(_TransactionProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'brand': instance.brand,
      'sku': instance.sku,
    };

_TransactionUser _$TransactionUserFromJson(Map<String, dynamic> json) =>
    _TransactionUser(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$TransactionUserToJson(_TransactionUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
    };
