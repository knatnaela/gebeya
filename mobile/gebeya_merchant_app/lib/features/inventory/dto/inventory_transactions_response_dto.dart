import 'package:json_annotation/json_annotation.dart';

import 'inventory_transaction_dto.dart';
import '../../products/dto/product_list_response_dto.dart';

part 'inventory_transactions_response_dto.g.dart';

@JsonSerializable()
class InventoryTransactionsResponseDto {
  const InventoryTransactionsResponseDto({
    required this.transactions,
    required this.pagination,
  });

  final List<InventoryTransactionDto> transactions;
  final PaginationDto pagination;

  factory InventoryTransactionsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$InventoryTransactionsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$InventoryTransactionsResponseDtoToJson(this);
}
