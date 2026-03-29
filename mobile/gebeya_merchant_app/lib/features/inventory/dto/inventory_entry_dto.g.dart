// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_entry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryEntryDto _$InventoryEntryDtoFromJson(Map<String, dynamic> json) =>
    InventoryEntryDto(
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
      paymentStatus: json['paymentStatus'] as String? ?? 'PAID',
      supplierName: json['supplierName'] as String?,
      supplierContact: json['supplierContact'] as String?,
      remainingQuantity: (json['remainingQuantity'] as num?)?.toInt(),
      unitCost: InventoryEntryDto._decimalFromJson(json['unitCost']),
      totalCost: InventoryEntryDto._decimalFromJson(json['totalCost']),
      paidAmount: InventoryEntryDto._decimalFromJson(json['paidAmount']),
      paymentDueDate: json['paymentDueDate'] == null
          ? null
          : DateTime.parse(json['paymentDueDate'] as String),
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      products: json['products'] == null
          ? null
          : EntryProductDto.fromJson(json['products'] as Map<String, dynamic>),
      locations: json['locations'] == null
          ? null
          : EntryLocationDto.fromJson(
              json['locations'] as Map<String, dynamic>,
            ),
      users: json['users'] == null
          ? null
          : EntryUserDto.fromJson(json['users'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InventoryEntryDtoToJson(InventoryEntryDto instance) =>
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
      'paymentStatus': instance.paymentStatus,
      'supplierName': instance.supplierName,
      'supplierContact': instance.supplierContact,
      'remainingQuantity': instance.remainingQuantity,
      'unitCost': InventoryEntryDto._decimalToJson(instance.unitCost),
      'totalCost': InventoryEntryDto._decimalToJson(instance.totalCost),
      'paidAmount': InventoryEntryDto._decimalToJson(instance.paidAmount),
      'paymentDueDate': instance.paymentDueDate?.toIso8601String(),
      'paidAt': instance.paidAt?.toIso8601String(),
      'products': instance.products,
      'locations': instance.locations,
      'users': instance.users,
    };

EntryProductDto _$EntryProductDtoFromJson(Map<String, dynamic> json) =>
    EntryProductDto(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      sku: json['sku'] as String?,
    );

Map<String, dynamic> _$EntryProductDtoToJson(EntryProductDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'brand': instance.brand,
      'sku': instance.sku,
    };

EntryLocationDto _$EntryLocationDtoFromJson(Map<String, dynamic> json) =>
    EntryLocationDto(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$EntryLocationDtoToJson(EntryLocationDto instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

EntryUserDto _$EntryUserDtoFromJson(Map<String, dynamic> json) => EntryUserDto(
  id: json['id'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$EntryUserDtoToJson(EntryUserDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
    };
