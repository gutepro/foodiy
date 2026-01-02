String resolveUserDisplayName(
  Map<String, dynamic>? userDoc, {
  String? chefName,
  String? authFallback,
  String fallback = 'Chef',
}) {
  final displayName = (userDoc?['displayName'] as String?)?.trim();
  if (displayName != null && displayName.isNotEmpty) return displayName;

  final chef = (userDoc?['chefName'] as String?)?.trim() ??
      (chefName?.trim() ?? '');
  if (chef.isNotEmpty) return chef;

  final auth = authFallback?.trim() ?? '';
  if (auth.isNotEmpty) return auth;

  return fallback;
}

String? resolveUserAvatar(
  Map<String, dynamic>? userDoc, {
  String? authFallback,
}) {
  final avatar =
      (userDoc?['chefAvatarUrl'] as String?) ?? (userDoc?['photoUrl'] as String?);
  if (avatar != null && avatar.trim().isNotEmpty) return avatar;
  final auth = authFallback?.trim();
  return (auth != null && auth.isNotEmpty) ? auth : null;
}
