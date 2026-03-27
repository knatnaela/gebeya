import 'package:json_annotation/json_annotation.dart';

part 'login_payload_dto.g.dart';

@JsonSerializable()
class LoginPayloadDto {
  const LoginPayloadDto({required this.token, required this.requiresPasswordChange});

  final String token;
  final bool requiresPasswordChange;

  factory LoginPayloadDto.fromJson(Map<String, dynamic> json) => _$LoginPayloadDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LoginPayloadDtoToJson(this);
}
