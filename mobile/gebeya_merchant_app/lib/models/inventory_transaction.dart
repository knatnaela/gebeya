import 'package:freezed_annotation/freezed_annotation.dart';

import 'location.dart';

part 'inventory_transaction.freezed.dart';
part 'inventory_transaction.g.dart';

enum InventoryTransactionType {
  sale,
  adjustment,
  restock,
  return_,
  transferIn,
  transferOut,
  stockIn,
}

@freezed
abstract class InventoryTransaction with _$InventoryTransaction {
  const factory InventoryTransaction({
    required String id,
    required String productId,
    required String locationId,
    required String userId,
    required InventoryTransactionType type,
    required int quantity,
    String? reason,
    String? referenceId,
    String? referenceType,
    required DateTime createdAt,
    // Nested objects (populated from DTO)
    TransactionProduct? product,
    Location? location,
    TransactionUser? user,
  }) = _InventoryTransaction;

  factory InventoryTransaction.fromJson(Map<String, dynamic> json) =>
      _$InventoryTransactionFromJson(json);
}

@freezed
abstract class TransactionProduct with _$TransactionProduct {
  const factory TransactionProduct({
    required String id,
    required String name,
    String? brand,
    String? sku,
  }) = _TransactionProduct;

  factory TransactionProduct.fromJson(Map<String, dynamic> json) =>
      _$TransactionProductFromJson(json);
}

@freezed
abstract class TransactionUser with _$TransactionUser {
  const factory TransactionUser({
    required String id,
    required String firstName,
    String? lastName,
    String? email,
  }) = _TransactionUser;

  factory TransactionUser.fromJson(Map<String, dynamic> json) =>
      _$TransactionUserFromJson(json);
}
