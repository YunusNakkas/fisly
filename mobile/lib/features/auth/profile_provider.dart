import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';

class Profile {
  final String id;
  final String email;
  final String? fullName;
  final String plan;
  final int quotaUsed;
  final int? quotaLimit;

  const Profile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.plan,
    required this.quotaUsed,
    required this.quotaLimit,
  });

  bool get isAtQuotaLimit => quotaLimit != null && quotaUsed >= quotaLimit!;

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
    id: j['id'] as String,
    email: j['email'] as String,
    fullName: j['full_name'] as String?,
    plan: j['plan'] as String,
    quotaUsed: (j['quota_used'] as num?)?.toInt() ?? 0,
    quotaLimit: (j['quota_limit'] as num?)?.toInt(),
  );
}

final profileProvider = FutureProvider.autoDispose<Profile>((ref) async {
  final api = ref.read(apiClientProvider);
  final res = await api.dio.get('/auth/me');
  return Profile.fromJson(res.data as Map<String, dynamic>);
});

class ProfileUpdater {
  final ApiClient _api;
  const ProfileUpdater(this._api);

  Future<void> updateName(String fullName) async {
    await _api.dio.patch('/auth/me', data: {'full_name': fullName});
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.dio.patch(
      '/auth/me',
      data: {'current_password': currentPassword, 'new_password': newPassword},
    );
  }
}

final profileUpdaterProvider = Provider<ProfileUpdater>((ref) {
  return ProfileUpdater(ref.read(apiClientProvider));
});
