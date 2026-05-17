import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/env.dart';
import '../storage/token_storage.dart';

const _baseUrl = Env.apiBaseUrl;

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(tokenStorageProvider);
  return ApiClient(storage);
});

class ApiClient {
  late final Dio _dio;
  late final Dio _refreshDio;
  final TokenStorage _storage;

  /// Triggered when refresh fails after a 401 response.
  /// Set by authProvider to avoid a circular dependency.
  Future<void> Function()? onUnauthorized;

  bool _refreshing = false;

  ApiClient(this._storage) {
    const timeout = Duration(seconds: 15);
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
      ),
    );
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (err, handler) async {
          final isAuth401 =
              err.response?.statusCode == 401 &&
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
              // Prevent multiple refresh attempts at the same time.
              return handler.next(err);
            }
            _refreshing = true;
            final res = await _refreshDio.post(
              '/auth/refresh',
              data: {'refresh_token': refresh},
            );
            await _storage.saveTokens(
              res.data['access_token'] as String,
              res.data['refresh_token'] as String,
            );

            // Retry the original request with the new token.
            final retryOptions = err.requestOptions;
            retryOptions.headers['Authorization'] =
                'Bearer ${res.data['access_token']}';
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
      ),
    );
  }

  Dio get dio => _dio;
}
