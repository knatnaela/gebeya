import 'package:json_annotation/json_annotation.dart';

part 'api_response_dto.g.dart';

/// Standard backend envelope:
/// { "success": true, "data": payload }
/// or { "success": false, "error": "..." }
@JsonSerializable(genericArgumentFactories: true)
class ApiResponseDto<T> {
  const ApiResponseDto({
    required this.success,
    this.data,
    this.error,
    this.message,
  });

  final bool success;
  final T? data;
  final String? error;
  final String? message;

  factory ApiResponseDto.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseDtoFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseDtoToJson(this, toJsonT);
}

