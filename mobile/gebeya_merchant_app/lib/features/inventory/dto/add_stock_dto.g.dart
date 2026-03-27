// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_stock_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddStockDto _$AddStockDtoFromJson(Map<String, dynamic> json) => AddStockDto(
  productId: json['productId'] as String,
  locationId: json['locationId'] as String?,
  quantity: (json['quantity'] as num).toInt(),
  batchNumber: json['batchNumber'] as String?,
  expirationDate: json['expirationDate'] == null
      ? null
      : DateTime.parse(json['expirationDate'] as String),
  receivedDate: json['receivedDate'] == null
      ? null
      : DateTime.parse(json['receivedDate'] as String),
  notes: json['notes'] as String?,
  paymentStatus: $enumDecodeNullable(
    _$PaymentStatusEnumMap,
    json['paymentStatus'],
  ),
  supplierName: json['supplierName'] as String?,
  supplierContact: json['supplierContact'] as String?,
  totalCost: (json['totalCost'] as num?)?.toDouble(),
  paidAmount: (json['paidAmount'] as num?)?.toDouble(),
  paymentDueDate: json['paymentDueDate'] == null
      ? null
      : DateTime.parse(json['paymentDueDate'] as String),
);

Map<String, dynamic> _$AddStockDtoToJson(
  AddStockDto instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'locationId': instance.locationId,
  'quantity': instance.quantity,
  'batchNumber': instance.batchNumber,
  'expirationDate': ?AddStockDto._dateToJson(instance.expirationDate),
  'receivedDate': ?AddStockDto._dateToJson(instance.receivedDate),
  'notes': instance.notes,
  'paymentStatus': ?AddStockDto._paymentStatusToJson(instance.paymentStatus),
  'supplierName': instance.supplierName,
  'supplierContact': instance.supplierContact,
  'totalCost': instance.totalCost,
  'paidAmount': instance.paidAmount,
  'paymentDueDate': ?AddStockDto._dateToJson(instance.paymentDueDate),
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.paid: 'paid',
  PaymentStatus.credit: 'credit',
  PaymentStatus.partial: 'partial',
};
