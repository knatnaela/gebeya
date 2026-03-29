// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Location _$LocationFromJson(Map<String, dynamic> json) => _Location(
  id: json['id'] as String,
  merchantId: json['merchantId'] as String,
  name: json['name'] as String,
  address: json['address'] as String?,
  phoneCountryIso: json['phoneCountryIso'] as String?,
  phoneDialCode: json['phoneDialCode'] as String?,
  phoneNationalNumber: json['phoneNationalNumber'] as String?,
  phone: json['phone'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  isDefault: json['isDefault'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$LocationToJson(_Location instance) => <String, dynamic>{
  'id': instance.id,
  'merchantId': instance.merchantId,
  'name': instance.name,
  'address': instance.address,
  'phoneCountryIso': instance.phoneCountryIso,
  'phoneDialCode': instance.phoneDialCode,
  'phoneNationalNumber': instance.phoneNationalNumber,
  'phone': instance.phone,
  'isActive': instance.isActive,
  'isDefault': instance.isDefault,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
