import 'package:json_annotation/json_annotation.dart';

import '../../../models/payment_status.dart';

part 'add_stock_dto.g.dart';

@JsonSerializable()
class AddStockDto {
  const AddStockDto({
    required this.productId,
    this.locationId,
    required this.quantity,
    this.batchNumber,
    this.expirationDate,
    this.receivedDate,
    this.notes,
    this.paymentStatus,
    this.supplierName,
    this.supplierContact,
    this.totalCost,
    this.paidAmount,
    this.paymentDueDate,
  });

  final String productId;
  final String? locationId;
  final int quantity;
  final String? batchNumber;

  @JsonKey(name: 'expirationDate', toJson: _dateToJson, includeIfNull: false)
  final DateTime? expirationDate;

  @JsonKey(name: 'receivedDate', toJson: _dateToJson, includeIfNull: false)
  final DateTime? receivedDate;

  final String? notes;

  @JsonKey(name: 'paymentStatus', toJson: _paymentStatusToJson, includeIfNull: false)
  final PaymentStatus? paymentStatus;

  final String? supplierName;
  final String? supplierContact;

  final double? totalCost;
  final double? paidAmount;

  @JsonKey(name: 'paymentDueDate', toJson: _dateToJson, includeIfNull: false)
  final DateTime? paymentDueDate;

  static String? _dateToJson(DateTime? date) {
    return date?.toIso8601String();
  }

  static String? _paymentStatusToJson(PaymentStatus? status) {
    return status?.toBackendString();
  }

  factory AddStockDto.fromJson(Map<String, dynamic> json) =>
      _$AddStockDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AddStockDtoToJson(this);
}
