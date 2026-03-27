// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_list_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductListResponseDto _$ProductListResponseDtoFromJson(
  Map<String, dynamic> json,
) => ProductListResponseDto(
  products: (json['products'] as List<dynamic>)
      .map((e) => ProductDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: PaginationDto.fromJson(
    json['pagination'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ProductListResponseDtoToJson(
  ProductListResponseDto instance,
) => <String, dynamic>{
  'products': instance.products,
  'pagination': instance.pagination,
};

PaginationDto _$PaginationDtoFromJson(Map<String, dynamic> json) =>
    PaginationDto(
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$PaginationDtoToJson(PaginationDto instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'total': instance.total,
      'totalPages': instance.totalPages,
    };
