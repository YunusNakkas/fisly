/// Build-time environment variables. Pass with `--dart-define=KEY=VALUE`.
///
/// Example:
///   flutter run --dart-define=SENTRY_DSN=https://... --dart-define=ENV=production
class Env {
  Env._();

  static const sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );
  static const environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );
}
