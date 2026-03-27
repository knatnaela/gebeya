import 'package:json_annotation/json_annotation.dart';

import '../../../models/inventory_entry.dart';
import '../../../models/location.dart';
import '../../../models/payment_status.dart';

part 'inventory_entry_dto.g.dart';

@JsonSerializable()
class InventoryEntryDto {
  const InventoryEntryDto({
    required this.id,
    required this.productId,
    required this.locationId,
    required this.quantity,
    this.batchNumber,
    this.expirationDate,
    required this.receivedDate,
    this.notes,
    required this.addedBy,
    @JsonKey(name: 'paymentStatus', fromJson: _paymentStatusFromJson) this.paymentStatus = 'PAID',
    this.supplierName,
    this.supplierContact,
    this.totalCost,
    this.paidAmount,
    this.paymentDueDate,
    this.paidAt,
    this.products,
    this.locations,
    this.users,
  });

  final String id;
  final String productId;
  final String locationId;
  final int quantity;
  final String? batchNumber;
  final DateTime? expirationDate;
  final DateTime receivedDate;
  final String? notes;
  final String addedBy;

  final String paymentStatus;

  final String? supplierName;
  final String? supplierContact;

  @JsonKey(name: 'totalCost', fromJson: _decimalFromJson, toJson: _decimalToJson)
  final double? totalCost;

  @JsonKey(name: 'paidAmount', fromJson: _decimalFromJson, toJson: _decimalToJson)
  final double? paidAmount;

  final DateTime? paymentDueDate;
  final DateTime? paidAt;

  @JsonKey(name: 'products')
  final EntryProductDto? products;

  @JsonKey(name: 'locations')
  final EntryLocationDto? locations;

  @JsonKey(name: 'users')
  final EntryUserDto? users;

  static String _paymentStatusFromJson(Object? json) {
    if (json == null) return 'PAID';
    return json.toString().toUpperCase();
  }

  static double? _decimalFromJson(Object? json) {
    if (json == null) return null;
    if (json is String) {
      if (json.isEmpty) return null;
      return double.tryParse(json);
    }
    // Handle edge cases where it might already be a number
    if (json is num) return json.toDouble();
    return null;
  }

  static Object? _decimalToJson(double? value) {
    return value;
  }

  factory InventoryEntryDto.fromJson(Map<String, dynamic> json) => _$InventoryEntryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$InventoryEntryDtoToJson(this);

  InventoryEntry toDomain() {
    return InventoryEntry(
      id: id,
      productId: productId,
      locationId: locationId,
      quantity: quantity,
      batchNumber: batchNumber,
      expirationDate: expirationDate,
      receivedDate: receivedDate,
      notes: notes,
      addedBy: addedBy,
      paymentStatus: PaymentStatusExtension.fromBackendString(paymentStatus),
      supplierName: supplierName,
      supplierContact: supplierContact,
      totalCost: totalCost,
      paidAmount: paidAmount,
      paymentDueDate: paymentDueDate,
      paidAt: paidAt,
      product: products?.toProductDomain(),
      location: locations?.toDomain(),
      user: users?.toDomain(),
    );
  }
}

@JsonSerializable()
class EntryProductDto {
  const EntryProductDto({required this.id, required this.name, this.brand, this.sku});

  final String id;
  final String name;
  final String? brand;
  final String? sku;

  factory EntryProductDto.fromJson(Map<String, dynamic> json) => _$EntryProductDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EntryProductDtoToJson(this);

  EntryProduct toProductDomain() {
    return EntryProduct(id: id, name: name, brand: brand, sku: sku);
  }
}

@JsonSerializable()
class EntryLocationDto {
  const EntryLocationDto({required this.id, required this.name});

  final String id;
  final String name;

  factory EntryLocationDto.fromJson(Map<String, dynamic> json) => _$EntryLocationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EntryLocationDtoToJson(this);

  Location toDomain() {
    return Location(
      id: id,
      merchantId: '', // Not available in entry response
      name: name,
      isActive: true, // Default
      isDefault: false, // Default
      createdAt: DateTime.now(), // Placeholder
      updatedAt: DateTime.now(), // Placeholder
    );
  }
}

@JsonSerializable()
class EntryUserDto {
  const EntryUserDto({required this.id, required this.firstName, this.lastName, this.email});

  final String id;
  final String firstName;
  final String? lastName;
  final String? email;

  factory EntryUserDto.fromJson(Map<String, dynamic> json) => _$EntryUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EntryUserDtoToJson(this);

  EntryUser toDomain() {
    return EntryUser(id: id, firstName: firstName, lastName: lastName, email: email);
  }
}
