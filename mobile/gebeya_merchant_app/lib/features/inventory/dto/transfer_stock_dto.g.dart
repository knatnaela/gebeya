// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_stock_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferStockDto _$TransferStockDtoFromJson(Map<String, dynamic> json) =>
    TransferStockDto(
      productId: json['productId'] as String,
      fromLocationId: json['fromLocationId'] as String,
      toLocationId: json['toLocationId'] as String,
      quantity: (json['quantity'] as num).toInt(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$TransferStockDtoToJson(TransferStockDto instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'fromLocationId': instance.fromLocationId,
      'toLocationId': instance.toLocationId,
      'quantity': instance.quantity,
      'notes': instance.notes,
    };
