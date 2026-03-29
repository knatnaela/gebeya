import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/dto/api_response_dto.dart';
import '../../core/api/endpoints.dart';
import '../../models/location.dart';
import '../inventory/dto/inventory_transaction_dto.dart';

final locationsRepositoryProvider = Provider<LocationsRepository>((ref) {
  return LocationsRepository(ref.watch(dioProvider));
});

class LocationsRepository {
  LocationsRepository(this._dio);

  final Dio _dio;

  Future<List<Location>> fetchLocations() async {
    final res = await _dio.get(Endpoints.locations);
    final envelope = ApiResponseDto<List<LocationDto>>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => (json as List<dynamic>)
          .map((e) => LocationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    final dtos = envelope.data ?? [];
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  Future<Location> fetchLocation(String id) async {
    final res = await _dio.get(Endpoints.location(id));
    final envelope = ApiResponseDto<LocationDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => LocationDto.fromJson(json as Map<String, dynamic>),
    );
    final dto = envelope.data;
    if (dto == null)
      throw const LocationsRepositoryException('Missing location data.');
    return dto.toDomain();
  }

  Future<Location> fetchDefaultLocation() async {
    final res = await _dio.get(Endpoints.locationsDefault);
    final envelope = ApiResponseDto<LocationDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => LocationDto.fromJson(json as Map<String, dynamic>),
    );

    final dto = envelope.data;
    if (dto == null)
      throw const LocationsRepositoryException(
        'Missing default location data.',
      );
    return dto.toDomain();
  }

  Future<Location> createLocation({
    required String name,
    String? address,
    String? phoneCountryIso,
    String? phoneNationalNumber,
    String? phone,
  }) async {
    final res = await _dio.post(
      Endpoints.locations,
      data: {
        'name': name,
        if (address != null && address.isNotEmpty) 'address': address,
        if (phoneCountryIso != null && phoneCountryIso.isNotEmpty) 'phoneCountryIso': phoneCountryIso,
        if (phoneNationalNumber != null && phoneNationalNumber.isNotEmpty)
          'phoneNationalNumber': phoneNationalNumber,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );
    final envelope = ApiResponseDto<LocationDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => LocationDto.fromJson(json as Map<String, dynamic>),
    );
    final dto = envelope.data;
    if (dto == null)
      throw const LocationsRepositoryException('Missing location data.');
    return dto.toDomain();
  }

  Future<Location> updateLocation(
    String id, {
    String? name,
    String? address,
    String? phoneCountryIso,
    String? phoneNationalNumber,
    String? phone,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (address != null) body['address'] = address;
    if (phoneCountryIso != null) body['phoneCountryIso'] = phoneCountryIso;
    if (phoneNationalNumber != null) body['phoneNationalNumber'] = phoneNationalNumber;
    if (phone != null) body['phone'] = phone;
    if (isActive != null) body['isActive'] = isActive;

    final res = await _dio.put(Endpoints.location(id), data: body);
    final envelope = ApiResponseDto<LocationDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => LocationDto.fromJson(json as Map<String, dynamic>),
    );
    final dto = envelope.data;
    if (dto == null)
      throw const LocationsRepositoryException('Missing location data.');
    return dto.toDomain();
  }

  Future<Location> deleteLocation(String id) async {
    final res = await _dio.delete(Endpoints.location(id));
    final envelope = ApiResponseDto<LocationDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => LocationDto.fromJson(json as Map<String, dynamic>),
    );
    final dto = envelope.data;
    if (dto == null)
      throw const LocationsRepositoryException('Missing location data.');
    return dto.toDomain();
  }

  Future<Location> setDefaultLocation(String id) async {
    final res = await _dio.patch(Endpoints.locationSetDefault(id));
    final envelope = ApiResponseDto<LocationDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => LocationDto.fromJson(json as Map<String, dynamic>),
    );
    final dto = envelope.data;
    if (dto == null)
      throw const LocationsRepositoryException('Missing location data.');
    return dto.toDomain();
  }
}

class LocationsRepositoryException implements Exception {
  const LocationsRepositoryException(this.message);
  final String message;

  @override
  String toString() => message;
}
