import 'package:json_annotation/json_annotation.dart';

import 'product_dto.dart';

part 'product_list_response_dto.g.dart';

@JsonSerializable()
class ProductListResponseDto {
  const ProductListResponseDto({
    required this.products,
    required this.pagination,
  });

  final List<ProductDto> products;
  final PaginationDto pagination;

  factory ProductListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ProductListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProductListResponseDtoToJson(this);
}

@JsonSerializable()
class PaginationDto {
  const PaginationDto({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory PaginationDto.fromJson(Map<String, dynamic> json) =>
      _$PaginationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationDtoToJson(this);
}
