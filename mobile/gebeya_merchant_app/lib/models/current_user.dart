import 'package:freezed_annotation/freezed_annotation.dart';

part 'current_user.freezed.dart';
part 'current_user.g.dart';

@freezed
abstract class CurrentUser with _$CurrentUser {
  const factory CurrentUser({
    required String id,
    required String email,
    String? firstName,
    String? lastName,
    @Default(false) bool requiresPasswordChange,
    @Default(<dynamic>[]) List<dynamic> permissions,
    /// ISO 4217 from `merchants` on /auth/me (display only).
    @Default('ETB') String merchantCurrency,
  }) = _CurrentUser;

  factory CurrentUser.fromJson(Map<String, dynamic> json) =>
      _$CurrentUserFromJson(json);
}

