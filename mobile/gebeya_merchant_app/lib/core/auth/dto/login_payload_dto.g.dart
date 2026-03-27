// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_payload_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginPayloadDto _$LoginPayloadDtoFromJson(Map<String, dynamic> json) =>
    LoginPayloadDto(
      token: json['token'] as String,
      requiresPasswordChange: json['requiresPasswordChange'] as bool,
    );

Map<String, dynamic> _$LoginPayloadDtoToJson(LoginPayloadDto instance) =>
    <String, dynamic>{
      'token': instance.token,
      'requiresPasswordChange': instance.requiresPasswordChange,
    };
