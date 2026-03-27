// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_transaction_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTransactionDto _$CreateTransactionDtoFromJson(
  Map<String, dynamic> json,
) => CreateTransactionDto(
  productId: json['productId'] as String,
  locationId: json['locationId'] as String?,
  type: $enumDecode(_$InventoryTransactionTypeEnumMap, json['type']),
  quantity: (json['quantity'] as num).toInt(),
  reason: json['reason'] as String?,
  referenceId: json['referenceId'] as String?,
  referenceType: json['referenceType'] as String?,
);

Map<String, dynamic> _$CreateTransactionDtoToJson(
  CreateTransactionDto instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'locationId': instance.locationId,
  'type': CreateTransactionDto._typeToJson(instance.type),
  'quantity': instance.quantity,
  'reason': instance.reason,
  'referenceId': instance.referenceId,
  'referenceType': instance.referenceType,
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
