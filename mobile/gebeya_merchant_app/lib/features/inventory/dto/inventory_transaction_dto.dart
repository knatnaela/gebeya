import 'package:json_annotation/json_annotation.dart';

import '../../../models/inventory_transaction.dart';
import '../../../models/location.dart';

part 'inventory_transaction_dto.g.dart';

@JsonSerializable()
class InventoryTransactionDto {
  const InventoryTransactionDto({
    required this.id,
    required this.productId,
    required this.locationId,
    required this.userId,
    required this.type,
    required this.quantity,
    this.reason,
    this.referenceId,
    this.referenceType,
    required this.createdAt,
    this.products,
    this.locations,
    this.users,
  });

  final String id;
  final String productId;
  final String locationId;
  final String userId;

  @JsonKey(fromJson: _typeFromJson)
  final InventoryTransactionType type;

  final int quantity;
  final String? reason;
  final String? referenceId;
  final String? referenceType;
  final DateTime createdAt;

  @JsonKey(name: 'products')
  final TransactionProductDto? products;

  @JsonKey(name: 'locations')
  final TransactionLocationDto? locations;

  @JsonKey(name: 'users')
  final TransactionUserDto? users;

  static InventoryTransactionType _typeFromJson(String value) {
    switch (value.toUpperCase()) {
      case 'SALE':
        return InventoryTransactionType.sale;
      case 'ADJUSTMENT':
        return InventoryTransactionType.adjustment;
      case 'RESTOCK':
        return InventoryTransactionType.restock;
      case 'RETURN':
        return InventoryTransactionType.return_;
      case 'TRANSFER_IN':
        return InventoryTransactionType.transferIn;
      case 'TRANSFER_OUT':
        return InventoryTransactionType.transferOut;
      case 'STOCK_IN':
        return InventoryTransactionType.stockIn;
      default:
        throw FormatException('Unknown transaction type: $value');
    }
  }

  factory InventoryTransactionDto.fromJson(Map<String, dynamic> json) => _$InventoryTransactionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$InventoryTransactionDtoToJson(this);

  InventoryTransaction toDomain() {
    final loc = locations;
    return InventoryTransaction(
      id: id,
      productId: productId,
      locationId: locationId,
      userId: userId,
      type: type,
      quantity: quantity,
      reason: reason,
      referenceId: referenceId,
      referenceType: referenceType,
      createdAt: createdAt,
      product: products?.toProductDomain(),
      location: locations?.toDomain(),
      user: users?.toDomain(),
    );
  }
}

@JsonSerializable()
class TransactionProductDto {
  const TransactionProductDto({required this.id, required this.name, this.brand, this.sku});

  final String id;
  final String name;
  final String? brand;
  final String? sku;

  factory TransactionProductDto.fromJson(Map<String, dynamic> json) => _$TransactionProductDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionProductDtoToJson(this);

  TransactionProduct toProductDomain() {
    return TransactionProduct(id: id, name: name, brand: brand, sku: sku);
  }
}

@JsonSerializable()
class TransactionLocationDto {
  const TransactionLocationDto({required this.id, required this.name});

  final String id;
  final String name;

  factory TransactionLocationDto.fromJson(Map<String, dynamic> json) => _$TransactionLocationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionLocationDtoToJson(this);

  Location toDomain() {
    return Location(
      id: id,
      merchantId: '', // Not available in transaction response
      name: name,
      isActive: true, // Default
      isDefault: false, // Default
      createdAt: DateTime.now(), // Placeholder
      updatedAt: DateTime.now(), // Placeholder
    );
  }
}

@JsonSerializable()
class LocationDto {
  const LocationDto({
    required this.id,
    required this.merchantId,
    required this.name,
    this.address,
    this.phone,
    this.isActive = true,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String merchantId;
  final String name;
  final String? address;
  final String? phone;
  final bool isActive;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory LocationDto.fromJson(Map<String, dynamic> json) => _$LocationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LocationDtoToJson(this);

  Location toDomain() {
    return Location(
      id: id,
      merchantId: merchantId,
      name: name,
      address: address,
      phone: phone,
      isActive: isActive,
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

@JsonSerializable()
class TransactionUserDto {
  const TransactionUserDto({required this.id, required this.firstName, this.lastName, this.email});

  final String id;
  final String firstName;
  final String? lastName;
  final String? email;

  factory TransactionUserDto.fromJson(Map<String, dynamic> json) => _$TransactionUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionUserDtoToJson(this);

  TransactionUser toDomain() {
    return TransactionUser(id: id, firstName: firstName, lastName: lastName, email: email);
  }
}
