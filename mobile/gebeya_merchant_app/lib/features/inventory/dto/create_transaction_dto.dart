import 'package:json_annotation/json_annotation.dart';

import '../../../models/inventory_transaction.dart';

part 'create_transaction_dto.g.dart';

@JsonSerializable()
class CreateTransactionDto {
  const CreateTransactionDto({
    required this.productId,
    this.locationId,
    required this.type,
    required this.quantity,
    this.reason,
    this.referenceId,
    this.referenceType,
  });

  final String productId;
  final String? locationId;

  @JsonKey(toJson: _typeToJson)
  final InventoryTransactionType type;

  final int quantity;
  final String? reason;
  final String? referenceId;
  final String? referenceType;

  static String _typeToJson(InventoryTransactionType type) {
    switch (type) {
      case InventoryTransactionType.sale:
        return 'SALE';
      case InventoryTransactionType.adjustment:
        return 'ADJUSTMENT';
      case InventoryTransactionType.restock:
        return 'RESTOCK';
      case InventoryTransactionType.return_:
        return 'RETURN';
      case InventoryTransactionType.transferIn:
        return 'TRANSFER_IN';
      case InventoryTransactionType.transferOut:
        return 'TRANSFER_OUT';
      case InventoryTransactionType.stockIn:
        return 'STOCK_IN';
    }
  }

  factory CreateTransactionDto.fromJson(Map<String, dynamic> json) =>
      _$CreateTransactionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTransactionDtoToJson(this);
}
