import '../../models/current_user.dart';

/// One permission row from `/auth/me` (matches backend `Permission` shape).
class PermissionEntry {
  const PermissionEntry({
    required this.featureSlug,
    required this.featureId,
    required this.actions,
  });

  final String featureSlug;
  final String featureId;
  final List<String> actions;

  static PermissionEntry? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final slug = map['featureSlug'];
    final id = map['featureId'];
    if (slug is! String || slug.isEmpty) return null;
    if (id is! String) return null;
    final actionsRaw = map['actions'];
    final actions = <String>[];
    if (actionsRaw is List) {
      for (final a in actionsRaw) {
        if (a is String) actions.add(a);
      }
    }
    return PermissionEntry(featureSlug: slug, featureId: id, actions: actions);
  }
}

/// Web-style `hasFeature(featureSlug)` using `/auth/me` permissions.
class MerchantPermissions {
  const MerchantPermissions._(this._slugs);

  factory MerchantPermissions.fromUser(CurrentUser user) {
    final slugs = <String>{};
    for (final raw in user.permissions) {
      final e = PermissionEntry.tryParse(raw);
      if (e != null) slugs.add(e.featureSlug);
    }
    return MerchantPermissions._(slugs);
  }

  /// Unauthenticated or unknown — deny gated features.
  factory MerchantPermissions.none() => const MerchantPermissions._(<String>{});

  final Set<String> _slugs;

  bool hasFeature(String featureSlug) => _slugs.contains(featureSlug);
}
