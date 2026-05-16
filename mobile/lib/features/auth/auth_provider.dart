import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/token_storage.dart';

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
      await _api.dio.get('/auth/me');
      if (mounted) state = AuthStatus.authenticated;
    } catch (_) {
      // 401 olursa interceptor refresh denedi; başarısızsa forceLogout state'i zaten anonymous yaptı
      if (mounted && state == AuthStatus.unknown) state = AuthStatus.anonymous;
    }
  }

  Future<void> login(String email, String password) async {
    final res = await _api.dio.post('/auth/login', data: {'email': email, 'password': password});
    await _storage.saveTokens(res.data['access_token'], res.data['refresh_token']);
    state = AuthStatus.authenticated;
  }

  Future<void> register(String email, String password, String fullName) async {
    final res = await _api.dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'full_name': fullName,
    });
    await _storage.saveTokens(res.data['access_token'], res.data['refresh_token']);
    state = AuthStatus.authenticated;
  }

  Future<void> logout() async {
    await _storage.clear();
    state = AuthStatus.anonymous;
  }

  /// 401 + refresh başarısız sonrası interceptor'dan çağrılır.
  Future<void> forceLogout() async {
    await _storage.clear();
    if (mounted) state = AuthStatus.anonymous;
  }
}
