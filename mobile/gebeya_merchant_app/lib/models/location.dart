import 'package:freezed_annotation/freezed_annotation.dart';

part 'location.freezed.dart';
part 'location.g.dart';

@freezed
abstract class Location with _$Location {
  const factory Location({
    required String id,
    required String merchantId,
    required String name,
    String? address,
    String? phoneCountryIso,
    String? phoneDialCode,
    String? phoneNationalNumber,
    String? phone,
    @Default(true) bool isActive,
    @Default(false) bool isDefault,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
}
