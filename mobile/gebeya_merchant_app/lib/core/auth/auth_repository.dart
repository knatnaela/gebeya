import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/dto/api_response_dto.dart';
import '../api/endpoints.dart';
import 'dto/current_user_dto.dart';
import 'dto/login_payload_dto.dart';
import '../../models/current_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<String> login({required String email, required String password}) async {
    final res = await _dio.post(Endpoints.login, data: {'email': email, 'password': password});

    final envelope = ApiResponseDto<LoginPayloadDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => LoginPayloadDto.fromJson(json as Map<String, dynamic>),
    );

    final token = envelope.data?.token;
    if (token != null && token.isNotEmpty) return token;

    throw const AuthRepositoryException('Login succeeded but token missing.');
  }

  Future<CurrentUser> me() async {
    final res = await _dio.get(Endpoints.me);
    final envelope = ApiResponseDto<CurrentUserDto>.fromJson(
      res.data as Map<String, dynamic>,
      (json) => CurrentUserDto.fromJson(json as Map<String, dynamic>),
    );

    final dto = envelope.data;
    if (dto == null) throw const AuthRepositoryException('Missing /auth/me data.');
    return dto.toDomain();
  }

  Future<void> changePassword({required String oldPassword, required String newPassword}) async {
    await _dio.post(Endpoints.changePassword, data: {'oldPassword': oldPassword, 'newPassword': newPassword});
  }

  Future<void> merchantRegister({
    required String businessName,
    required String businessEmail,
    String? businessPhone,
    String? businessAddress,
    required String adminFirstName,
    String? adminLastName,
    required String adminPassword,
  }) async {
    await _dio.post(
      Endpoints.merchantRegister,
      data: {
        'name': businessName,
        'email': businessEmail,
        'phone': businessPhone,
        'address': businessAddress,
        'firstName': adminFirstName,
        'lastName': adminLastName,
        'password': adminPassword,
      },
    );
  }
}

class AuthRepositoryException implements Exception {
  const AuthRepositoryException(this.message);
  final String message;

  @override
  String toString() => message;
}
