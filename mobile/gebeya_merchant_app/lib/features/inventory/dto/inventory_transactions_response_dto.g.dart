// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_transactions_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryTransactionsResponseDto _$InventoryTransactionsResponseDtoFromJson(
  Map<String, dynamic> json,
) => InventoryTransactionsResponseDto(
  transactions: (json['transactions'] as List<dynamic>)
      .map((e) => InventoryTransactionDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: PaginationDto.fromJson(
    json['pagination'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$InventoryTransactionsResponseDtoToJson(
  InventoryTransactionsResponseDto instance,
) => <String, dynamic>{
  'transactions': instance.transactions,
  'pagination': instance.pagination,
};
