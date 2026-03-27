import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/current_user.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
  const factory AuthState.requiresPasswordChange({
    CurrentUser? user,
  }) = AuthRequiresPasswordChange;
  const factory AuthState.authenticated({
    required CurrentUser user,
  }) = AuthAuthenticated;
}

