import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/token_storage.dart';
import '../../core/billing/billing_service.dart';

enum AuthStatus { unknown, authenticated, anonymous }

final authProvider = StateNotifierProvider<AuthNotifier, AuthStatus>((ref) {
  final api = ref.read(apiClientProvider);
  final storage = ref.read(tokenStorageProvider);
  final notifier = AuthNotifier(api, storage);
  api.onUnauthorized = () async {
    await notifier.forceLogout();
  };
  return notifier;
});

class AuthNotifier extends StateNotifier<AuthStatus> {
  final ApiClient _api;
  final TokenStorage _storage;

  AuthNotifier(this._api, this._storage) : super(AuthStatus.unknown) {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final token = await _storage.getAccessToken();
    if (token == null) {
      state = AuthStatus.anonymous;
      return;
    }
    try {
      final res = await _api.dio.get('/auth/me');
      await billingLogIn(res.data['id'] as String);
      if (mounted) state = AuthStatus.authenticated;
    } catch (_) {
      // If a 401 occurs, the interceptor already tried refresh. On failure,
      // forceLogout already moved the state to anonymous.
      if (mounted && state == AuthStatus.unknown) state = AuthStatus.anonymous;
    }
  }

  Future<void> login(String email, String password) async {
    final res = await _api.dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    await _storage.saveTokens(
      res.data['access_token'],
      res.data['refresh_token'],
    );
    await _syncBilling();
    state = AuthStatus.authenticated;
  }

  Future<void> register(String email, String password, String fullName) async {
    final res = await _api.dio.post(
      '/auth/register',
      data: {'email': email, 'password': password, 'full_name': fullName},
    );
    await _storage.saveTokens(
      res.data['access_token'],
      res.data['refresh_token'],
    );
    await _syncBilling();
    state = AuthStatus.authenticated;
  }

  /// Backend kullanıcı UUID'sini RevenueCat'e bağlar (webhook eşleşmesi için).
  Future<void> _syncBilling() async {
    try {
      final res = await _api.dio.get('/auth/me');
      await billingLogIn(res.data['id'] as String);
    } catch (_) {}
  }

  Future<void> logout() async {
    try {
      await _api.dio.post('/auth/logout');
    } catch (_) {
      // Perform local logout even when the server is unreachable.
    }
    await billingLogOut();
    await _storage.clear();
    state = AuthStatus.anonymous;
  }

  Future<void> forgotPassword(String email) async {
    await _api.dio.post('/auth/forgot-password', data: {'email': email});
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await _api.dio.post(
      '/auth/reset-password',
      data: {'token': token, 'new_password': newPassword},
    );
  }

  /// Hesabı ve tüm verileri kalıcı olarak siler (KVKK / App Store şartı).
  Future<void> deleteAccount() async {
    await _api.dio.delete('/auth/me');
    await billingLogOut();
    await _storage.clear();
    state = AuthStatus.anonymous;
  }

  /// Called by the interceptor after a 401 + failed refresh.
  Future<void> forceLogout() async {
    await billingLogOut();
    await _storage.clear();
    if (mounted) state = AuthStatus.anonymous;
  }
}
