import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/subscription/subscription_controller.dart';
import 'auth_repository.dart';
import 'auth_state.dart';
import 'token_storage.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    unawaited(_bootstrap());
    return const AuthState.loading();
  }

  Future<void> _bootstrap() async {
    final token = await ref.read(authTokenStorageProvider).read();
    if (token == null || token.isEmpty) {
      state = const AuthState.unauthenticated();
      return;
    }

    try {
      final user = await ref.read(authRepositoryProvider).me();
      if (user.requiresPasswordChange) {
        state = AuthState.requiresPasswordChange(user: user);
      } else {
        state = AuthState.authenticated(user: user);
      }
      await ref.read(subscriptionControllerProvider.notifier).refresh();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await ref.read(authTokenStorageProvider).clear();
        state = const AuthState.unauthenticated();
        return;
      }
      state = const AuthState.unauthenticated();
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> _finishLogin(String token) async {
    await ref.read(authTokenStorageProvider).write(token);

    final user = await ref.read(authRepositoryProvider).me();
    if (user.requiresPasswordChange) {
      state = AuthState.requiresPasswordChange(user: user);
    } else {
      state = AuthState.authenticated(user: user);
    }
    await ref.read(subscriptionControllerProvider.notifier).refresh();
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthState.loading();

    try {
      final token = await ref.read(authRepositoryProvider).login(email: email, password: password);
      await _finishLogin(token);
    } on DioException catch (e) {
      state = const AuthState.unauthenticated();
      throw AuthControllerException(_messageFromDio(e));
    } catch (e) {
      state = const AuthState.unauthenticated();
      throw AuthControllerException(e.toString());
    }
  }

  Future<void> loginWithPhonePassword({
    required String phoneCountryIso,
    required String phoneNationalNumber,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final token = await ref.read(authRepositoryProvider).loginWithPhonePassword(
            phoneCountryIso: phoneCountryIso,
            phoneNationalNumber: phoneNationalNumber,
            password: password,
          );
      await _finishLogin(token);
    } on DioException catch (e) {
      state = const AuthState.unauthenticated();
      throw AuthControllerException(_messageFromDio(e));
    } catch (e) {
      state = const AuthState.unauthenticated();
      throw AuthControllerException(e.toString());
    }
  }

  Future<String?> startGatewayLogin({
    required String phoneCountryIso,
    required String phoneNationalNumber,
  }) async {
    try {
      return await ref.read(authRepositoryProvider).gatewayLoginStart(
            phoneCountryIso: phoneCountryIso,
            phoneNationalNumber: phoneNationalNumber,
          );
    } on DioException catch (e) {
      throw AuthControllerException(_messageFromDio(e));
    } catch (e) {
      throw AuthControllerException(e.toString());
    }
  }

  Future<void> gatewayLoginVerify({
    required String requestId,
    required String code,
  }) async {
    state = const AuthState.loading();
    try {
      final token = await ref.read(authRepositoryProvider).gatewayLoginVerify(
            requestId: requestId,
            code: code,
          );
      await _finishLogin(token);
    } on DioException catch (e) {
      state = const AuthState.unauthenticated();
      throw AuthControllerException(_messageFromDio(e));
    } catch (e) {
      state = const AuthState.unauthenticated();
      throw AuthControllerException(e.toString());
    }
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
    try {
      await ref
          .read(authRepositoryProvider)
          .merchantRegister(
            businessName: businessName,
            businessEmail: businessEmail,
            businessPhoneE164: businessPhoneE164,
            businessAddress: businessAddress,
            adminFirstName: adminFirstName,
            adminLastName: adminLastName,
            adminPassword: adminPassword,
          );
    } on DioException catch (e) {
      throw AuthControllerException(_messageFromDio(e));
    } catch (e) {
      throw AuthControllerException(e.toString());
    }
  }

  Future<void> changePassword({required String oldPassword, required String newPassword}) async {
    try {
      await ref.read(authRepositoryProvider).changePassword(oldPassword: oldPassword, newPassword: newPassword);
      await logout();
    } on DioException catch (e) {
      throw AuthControllerException(_messageFromDio(e));
    } catch (e) {
      throw AuthControllerException(e.toString());
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await ref.read(authRepositoryProvider).forgotPassword(email);
    } on DioException catch (e) {
      throw AuthControllerException(_messageFromDio(e));
    } catch (e) {
      throw AuthControllerException(e.toString());
    }
  }

  Future<void> resetPassword({required String token, required String newPassword}) async {
    try {
      await ref.read(authRepositoryProvider).resetPassword(token: token, newPassword: newPassword);
    } on DioException catch (e) {
      throw AuthControllerException(_messageFromDio(e));
    } catch (e) {
      throw AuthControllerException(e.toString());
    }
  }

  Future<void> updateProfile({required String firstName, required String lastName}) async {
    try {
      await ref.read(authRepositoryProvider).updateProfile(firstName: firstName, lastName: lastName);
      final user = await ref.read(authRepositoryProvider).me();
      if (user.requiresPasswordChange) {
        state = AuthState.requiresPasswordChange(user: user);
      } else {
        state = AuthState.authenticated(user: user);
      }
      await ref.read(subscriptionControllerProvider.notifier).refresh();
    } on DioException catch (e) {
      throw AuthControllerException(_messageFromDio(e));
    } catch (e) {
      throw AuthControllerException(e.toString());
    }
  }

  Future<void> logout() async {
    await ref.read(authTokenStorageProvider).clear();
    ref.read(subscriptionControllerProvider.notifier).clear();
    state = const AuthState.unauthenticated();
  }

  /// Called by network interceptors when the backend returns a 401.
  void onUnauthorized() {
    state = const AuthState.unauthenticated();
  }
}

String _messageFromDio(DioException e) {
  final data = e.response?.data;
  if (data is Map) {
    final msg = data['error'] ?? data['message'];
    if (msg is String && msg.trim().isNotEmpty) return msg;
  }
  return e.message ?? 'Request failed';
}

class AuthControllerException implements Exception {
  const AuthControllerException(this.message);
  final String message;

  @override
  String toString() => message;
}
