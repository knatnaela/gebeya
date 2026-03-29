// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InventoryEntry _$InventoryEntryFromJson(Map<String, dynamic> json) =>
    _InventoryEntry(
      id: json['id'] as String,
      productId: json['productId'] as String,
      locationId: json['locationId'] as String,
      quantity: (json['quantity'] as num).toInt(),
      batchNumber: json['batchNumber'] as String?,
      expirationDate: json['expirationDate'] == null
          ? null
          : DateTime.parse(json['expirationDate'] as String),
      receivedDate: DateTime.parse(json['receivedDate'] as String),
      notes: json['notes'] as String?,
      addedBy: json['addedBy'] as String,
      paymentStatus:
          $enumDecodeNullable(_$PaymentStatusEnumMap, json['paymentStatus']) ??
          PaymentStatus.paid,
      supplierName: json['supplierName'] as String?,
      supplierContact: json['supplierContact'] as String?,
      remainingQuantity: (json['remainingQuantity'] as num?)?.toInt(),
      unitCost: (json['unitCost'] as num?)?.toDouble(),
      totalCost: (json['totalCost'] as num?)?.toDouble(),
      paidAmount: (json['paidAmount'] as num?)?.toDouble(),
      paymentDueDate: json['paymentDueDate'] == null
          ? null
          : DateTime.parse(json['paymentDueDate'] as String),
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      product: json['product'] == null
          ? null
          : EntryProduct.fromJson(json['product'] as Map<String, dynamic>),
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      user: json['user'] == null
          ? null
          : EntryUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InventoryEntryToJson(_InventoryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'locationId': instance.locationId,
      'quantity': instance.quantity,
      'batchNumber': instance.batchNumber,
      'expirationDate': instance.expirationDate?.toIso8601String(),
      'receivedDate': instance.receivedDate.toIso8601String(),
      'notes': instance.notes,
      'addedBy': instance.addedBy,
      'paymentStatus': _$PaymentStatusEnumMap[instance.paymentStatus]!,
      'supplierName': instance.supplierName,
      'supplierContact': instance.supplierContact,
      'remainingQuantity': instance.remainingQuantity,
      'unitCost': instance.unitCost,
      'totalCost': instance.totalCost,
      'paidAmount': instance.paidAmount,
      'paymentDueDate': instance.paymentDueDate?.toIso8601String(),
      'paidAt': instance.paidAt?.toIso8601String(),
      'product': instance.product,
      'location': instance.location,
      'user': instance.user,
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.paid: 'paid',
  PaymentStatus.credit: 'credit',
  PaymentStatus.partial: 'partial',
};

_EntryProduct _$EntryProductFromJson(Map<String, dynamic> json) =>
    _EntryProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      sku: json['sku'] as String?,
    );

Map<String, dynamic> _$EntryProductToJson(_EntryProduct instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'brand': instance.brand,
      'sku': instance.sku,
    };

_EntryUser _$EntryUserFromJson(Map<String, dynamic> json) => _EntryUser(
  id: json['id'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$EntryUserToJson(_EntryUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
    };
