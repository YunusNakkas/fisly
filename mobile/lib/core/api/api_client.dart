import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/token_storage.dart';

const _baseUrl = 'http://127.0.0.1:8000/api/v1';

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(tokenStorageProvider);
  return ApiClient(storage);
});

class ApiClient {
  late final Dio _dio;
  late final Dio _refreshDio;
  final TokenStorage _storage;

  /// 401 + refresh başarısız olduğunda tetiklenir.
  /// authProvider tarafından set edilir, döngüsel bağımlılığı önler.
  Future<void> Function()? onUnauthorized;

  bool _refreshing = false;

  ApiClient(this._storage) {
    const timeout = Duration(seconds: 15);
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
    ));
    _refreshDio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (err, handler) async {
        final isAuth401 = err.response?.statusCode == 401 &&
            !err.requestOptions.path.contains('/auth/refresh') &&
            !err.requestOptions.path.contains('/auth/login') &&
            !err.requestOptions.path.contains('/auth/register');

        if (!isAuth401) {
          return handler.next(err);
        }

        final refresh = await _storage.getRefreshToken();
        if (refresh == null) {
          await onUnauthorized?.call();
          return handler.next(err);
        }

        try {
          if (_refreshing) {
            // Aynı anda birden fazla refresh denemesini engelle
            return handler.next(err);
          }
          _refreshing = true;
          final res = await _refreshDio.post('/auth/refresh', data: {'refresh_token': refresh});
          await _storage.saveTokens(
            res.data['access_token'] as String,
            res.data['refresh_token'] as String,
          );

          // Orijinal isteği yeni token ile tekrarla
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer ${res.data['access_token']}';
          final retried = await _dio.fetch(retryOptions);
          return handler.resolve(retried);
        } catch (_) {
          await _storage.clear();
          await onUnauthorized?.call();
          return handler.next(err);
        } finally {
          _refreshing = false;
        }
      },
    ));
  }

  Dio get dio => _dio;
}
