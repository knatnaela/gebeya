// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionStatusDto _$SubscriptionStatusDtoFromJson(
  Map<String, dynamic> json,
) => SubscriptionStatusDto(
  status: json['status'] as String,
  isActive: json['isActive'] as bool,
  daysRemaining: (json['daysRemaining'] as num?)?.toInt(),
  trialEndDate: json['trialEndDate'] == null
      ? null
      : DateTime.parse(json['trialEndDate'] as String),
);

Map<String, dynamic> _$SubscriptionStatusDtoToJson(
  SubscriptionStatusDto instance,
) => <String, dynamic>{
  'status': instance.status,
  'isActive': instance.isActive,
  'daysRemaining': instance.daysRemaining,
  'trialEndDate': instance.trialEndDate?.toIso8601String(),
};
