// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentUserDto _$CurrentUserDtoFromJson(Map<String, dynamic> json) =>
    CurrentUserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      requiresPasswordChange: json['requiresPasswordChange'] as bool? ?? false,
      permissions: json['permissions'] as List<dynamic>? ?? const <dynamic>[],
      merchants: _merchantsFromJson(json['merchants']),
    );

Map<String, dynamic> _$CurrentUserDtoToJson(CurrentUserDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'requiresPasswordChange': instance.requiresPasswordChange,
      'permissions': instance.permissions,
      'merchants': instance.merchants,
    };
