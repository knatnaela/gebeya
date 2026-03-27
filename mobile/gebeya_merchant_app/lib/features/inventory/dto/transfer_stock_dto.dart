import 'package:json_annotation/json_annotation.dart';

part 'transfer_stock_dto.g.dart';

@JsonSerializable()
class TransferStockDto {
  const TransferStockDto({
    required this.productId,
    required this.fromLocationId,
    required this.toLocationId,
    required this.quantity,
    this.notes,
  });

  final String productId;
  final String fromLocationId;
  final String toLocationId;
  final int quantity;
  final String? notes;

  factory TransferStockDto.fromJson(Map<String, dynamic> json) =>
      _$TransferStockDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TransferStockDtoToJson(this);
}
