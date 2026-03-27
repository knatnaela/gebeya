import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../auth/token_storage.dart';
import '../../features/subscription/subscription_controller.dart';

const _trialExpiredMessage = 'Trial subscription has expired';

class AuthHeaderInterceptor extends Interceptor {
  AuthHeaderInterceptor(this.ref);

  final Ref ref;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await ref.read(authTokenStorageProvider).read();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class GlobalErrorInterceptor extends Interceptor {
  GlobalErrorInterceptor(this.ref);

  final Ref ref;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await ref.read(authTokenStorageProvider).clear();
      ref.read(subscriptionControllerProvider.notifier).clear();
      ref.read(authControllerProvider.notifier).onUnauthorized();
    }

    if (err.response?.statusCode == 403 && _isTrialExpired(err.response?.data)) {
      ref
          .read(subscriptionControllerProvider.notifier)
          .setExpired(message: _trialExpiredMessage);
    }

    handler.next(err);
  }
}

bool _isTrialExpired(Object? data) {
  if (data is Map) {
    final error = data['error'] ?? data['message'];
    if (error is String && error.trim() == _trialExpiredMessage) return true;
  }
  if (data is String && data.contains(_trialExpiredMessage)) return true;
  return false;
}

