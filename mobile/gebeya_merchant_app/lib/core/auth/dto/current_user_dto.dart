import 'package:json_annotation/json_annotation.dart';

import '../../../models/current_user.dart';

part 'current_user_dto.g.dart';

Map<String, dynamic>? _merchantsFromJson(Object? json) {
  if (json is Map<String, dynamic>) return json;
  if (json is Map) return Map<String, dynamic>.from(json);
  return null;
}

/// DTO for GET /api/auth/me (payload inside the standard ApiResponseDto envelope).
@JsonSerializable()
class CurrentUserDto {
  const CurrentUserDto({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.requiresPasswordChange = false,
    this.permissions = const <dynamic>[],
    this.merchants,
  });

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final bool requiresPasswordChange;

  /// Backend returns a complex permissions structure; we keep it flexible here.
  final List<dynamic> permissions;

  /// Nested merchant row when user is MERCHANT_* (Prisma relation name).
  @JsonKey(fromJson: _merchantsFromJson)
  final Map<String, dynamic>? merchants;

  factory CurrentUserDto.fromJson(Map<String, dynamic> json) =>
      _$CurrentUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentUserDtoToJson(this);

  CurrentUser toDomain() {
    var currency = 'ETB';
    final m = merchants;
    if (m != null) {
      final c = m['currency'];
      if (c is String && c.trim().isNotEmpty) {
        currency = c.trim().toUpperCase();
      }
    }
    return CurrentUser(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      requiresPasswordChange: requiresPasswordChange,
      permissions: permissions,
      merchantCurrency: currency,
    );
  }
}

