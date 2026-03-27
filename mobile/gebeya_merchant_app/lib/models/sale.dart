import 'package:freezed_annotation/freezed_annotation.dart';

part 'sale.freezed.dart';

@freezed
abstract class SaleSeller with _$SaleSeller {
  const factory SaleSeller({
    required String id,
    String? firstName,
    String? lastName,
    String? email,
  }) = _SaleSeller;
}

@freezed
abstract class SaleLineItem with _$SaleLineItem {
  const factory SaleLineItem({
    required String id,
    required String productId,
    required String productName,
    String? brand,
    String? sku,
    String? size,
    required int quantity,
    required num unitPrice,
    required num defaultPrice,
    required num totalPrice,
    required num costPrice,
  }) = _SaleLineItem;
}

@freezed
abstract class Sale with _$Sale {
  const factory Sale({
    required String id,
    required DateTime saleDate,
    required DateTime createdAt,
    required num totalAmount,
    num? platformFee,
    String? customerName,
    String? customerPhone,
    String? notes,
    required num netIncome,
    required num profitMargin,
    required num costOfGoodsSold,
    @Default(<SaleLineItem>[]) List<SaleLineItem> items,
    SaleSeller? seller,
    String? merchantName,
  }) = _Sale;
}
