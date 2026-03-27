class CreateSaleItemDto {
  const CreateSaleItemDto({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final int quantity;
  final num unitPrice;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };
}

class CreateSaleDto {
  const CreateSaleDto({
    required this.items,
    this.locationId,
    this.notes,
    this.saleDate,
    this.customerName,
    this.customerPhone,
  });

  final List<CreateSaleItemDto> items;
  final String? locationId;
  final String? notes;
  /// `YYYY-MM-DD` or ISO string.
  final String? saleDate;
  final String? customerName;
  final String? customerPhone;

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      if (locationId != null && locationId!.isNotEmpty) 'locationId': locationId,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (saleDate != null && saleDate!.isNotEmpty) 'saleDate': saleDate,
      if (customerName != null && customerName!.isNotEmpty) 'customerName': customerName,
      if (customerPhone != null && customerPhone!.isNotEmpty) 'customerPhone': customerPhone,
    };
  }
}
