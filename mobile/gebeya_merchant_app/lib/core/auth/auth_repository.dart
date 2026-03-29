import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/dto/api_response_dto.dart';
import '../api/endpoints.dart';
import 'dto/current_user_dto.dart';
import 'dto/login_payload_dto.dart';
import '../../models/current_user.dart';
import '../phone/phone_api_payload.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<String> login({required String email, required String password}) async {
    final res = await _dio.post(Endpoints.login, data: {'email': email, 'password': password});
    return _tokenFromLoginResponse(res.data);
  }

  Future<String> loginWithPhonePassword({
    required String phoneCountryIso,
    required String phoneNationalNumber,
    required String password,
  }) async {
    final res = await _dio.post(
      Endpoints.login,
      data: {
        'phoneCountryIso': phoneCountryIso,
        'phoneNationalNumber': phoneNationalNumber,
        'password': password,
      },
    );
    return _tokenFromLoginResponse(res.data);
  }

  String _tokenFromLoginResponse(dynamic data) {
    final envelope = ApiResponseDto<LoginPayloadDto>.fromJson(
      data as Map<String, dynamic>,
      (json) => LoginPayloadDto.fromJson(json as Map<String, dynamic>),
    );

    final token = envelope.data?.token;
    if (token != null && token.isNotEmpty) return token;

    throw const AuthRepositoryException('Login succeeded but token missing.');
  }

  /// Returns ISO codes for phone-first login UX (from platform settings).
  Future<List<String>> fetchAuthPublicConfig() async {
    final res = await _dio.get(Endpoints.authPublicConfig);
    final map = res.data as Map<String, dynamic>;
    if (map['success'] != true) {
      return const [];
    }
    final data = map['data'] as Map<String, dynamic>?;
    final raw = data?['phoneFirstCountryIsoCodes'];
    if (raw is List) {
      return raw.map((e) => e.toString().toUpperCase()).where((e) => e.length == 2).toList();
    }
    return const [];
  }

  /// Telegram Gateway OTP start. Returns request id when a code was sent.
  Future<String?> gatewayLoginStart({
    required String phoneCountryIso,
    required String phoneNationalNumber,
  }) async {
    final res = await _dio.post(
      Endpoints.authGatewayStart,
      data: {
        'phoneCountryIso': phoneCountryIso,
        'phoneNationalNumber': phoneNationalNumber,
      },
    );
    final map = res.data as Map<String, dynamic>;
    if (map['success'] != true) return null;
    final data = map['data'];
    return _parseGatewayRequestId(data);
  }

  Future<String> gatewayLoginVerify({
    required String requestId,
    required String code,
  }) async {
    final res = await _dio.post(
      Endpoints.authGatewayVerify,
      data: {'requestId': requestId, 'code': code},
    );
    return _tokenFromLoginResponse(res.data);
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

  Future<void> forgotPassword(String email) async {
    await _dio.post(Endpoints.forgotPassword, data: {'email': email.trim()});
  }

  Future<void> resetPassword({required String token, required String newPassword}) async {
    await _dio.post(
      Endpoints.resetPassword,
      data: {'token': token.trim(), 'newPassword': newPassword},
    );
  }

  Future<void> updateProfile({required String firstName, required String lastName}) async {
    await _dio.patch(
      Endpoints.usersMe,
      data: {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
      },
    );
  }

  Future<void> merchantRegister({
    required String businessName,
    required String businessEmail,
    String? businessPhoneE164,
    String? businessAddress,
    required String adminFirstName,
    String? adminLastName,
    required String adminPassword,
  }) async {
    final phone = PhoneApiPayload.merchantOrLocation(businessPhoneE164);
    await _dio.post(
      Endpoints.merchantRegister,
      data: {
        'name': businessName,
        'email': businessEmail,
        if (phone != null) ...phone,
        'address': businessAddress,
        'firstName': adminFirstName,
        'lastName': adminLastName,
        'password': adminPassword,
      },
    );
  }
}

String? _parseGatewayRequestId(Object? data) {
  if (data is! Map) return null;
  final m = Map<String, dynamic>.from(data);
  final raw = m['requestId'] ?? m['request_id'];
  if (raw is String && raw.trim().isNotEmpty) return raw.trim();
  return null;
}

class AuthRepositoryException implements Exception {
  const AuthRepositoryException(this.message);
  final String message;

  @override
  String toString() => message;
}
