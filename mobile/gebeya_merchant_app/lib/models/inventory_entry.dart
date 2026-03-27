import 'package:freezed_annotation/freezed_annotation.dart';

import 'location.dart';
import 'payment_status.dart';

part 'inventory_entry.freezed.dart';
part 'inventory_entry.g.dart';

@freezed
abstract class InventoryEntry with _$InventoryEntry {
  const factory InventoryEntry({
    required String id,
    required String productId,
    required String locationId,
    required int quantity,
    String? batchNumber,
    DateTime? expirationDate,
    required DateTime receivedDate,
    String? notes,
    required String addedBy,
    @Default(PaymentStatus.paid) PaymentStatus paymentStatus,
    String? supplierName,
    String? supplierContact,
    double? totalCost,
    double? paidAmount,
    DateTime? paymentDueDate,
    DateTime? paidAt,
    // Nested objects (populated from DTO)
    EntryProduct? product,
    Location? location,
    EntryUser? user,
  }) = _InventoryEntry;

  factory InventoryEntry.fromJson(Map<String, dynamic> json) =>
      _$InventoryEntryFromJson(json);
}

@freezed
abstract class EntryProduct with _$EntryProduct {
  const factory EntryProduct({
    required String id,
    required String name,
    String? brand,
    String? sku,
  }) = _EntryProduct;

  factory EntryProduct.fromJson(Map<String, dynamic> json) =>
      _$EntryProductFromJson(json);
}

@freezed
abstract class EntryUser with _$EntryUser {
  const factory EntryUser({
    required String id,
    required String firstName,
    String? lastName,
    String? email,
  }) = _EntryUser;

  factory EntryUser.fromJson(Map<String, dynamic> json) =>
      _$EntryUserFromJson(json);
}
