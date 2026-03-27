// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CurrentUser _$CurrentUserFromJson(Map<String, dynamic> json) => _CurrentUser(
  id: json['id'] as String,
  email: json['email'] as String,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  requiresPasswordChange: json['requiresPasswordChange'] as bool? ?? false,
  permissions: json['permissions'] as List<dynamic>? ?? const <dynamic>[],
  merchantCurrency: json['merchantCurrency'] as String? ?? 'ETB',
);

Map<String, dynamic> _$CurrentUserToJson(_CurrentUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'requiresPasswordChange': instance.requiresPasswordChange,
      'permissions': instance.permissions,
      'merchantCurrency': instance.merchantCurrency,
    };
