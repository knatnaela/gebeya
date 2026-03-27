import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../core/api/api_client.dart';
import '../../core/api/dto/api_response_dto.dart';
import '../../core/api/endpoints.dart';

part 'subscription_repository.g.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(ref.watch(dioProvider));
});

class SubscriptionRepository {
  SubscriptionRepository(this._dio);

  final Dio _dio;

  Future<SubscriptionStatusDto> fetchStatus() async {
    final res = await _dio.get(Endpoints.subscriptionStatus);
    final envelope = ApiResponseDto<SubscriptionStatusDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => SubscriptionStatusDto.fromJson(json as Map<String, dynamic>),
    );

    final dto = envelope.data;
    if (dto == null) {
      throw const SubscriptionRepositoryException(
        'Missing subscription status data.',
      );
    }
    return dto;
  }
}

@JsonSerializable()
class SubscriptionStatusDto {
  const SubscriptionStatusDto({
    required this.status,
    required this.isActive,
    this.daysRemaining,
    this.trialEndDate,
  });

  final String status;
  final bool isActive;
  final int? daysRemaining;
  final DateTime? trialEndDate;

  factory SubscriptionStatusDto.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionStatusDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionStatusDtoToJson(this);
}

class SubscriptionRepositoryException implements Exception {
  const SubscriptionRepositoryException(this.message);
  final String message;

  @override
  String toString() => message;
}

