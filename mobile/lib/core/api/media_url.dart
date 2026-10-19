import '../config/env.dart';

/// Sunucudan gelen medya URL'ini mutlak hale getirir.
/// Prod'da (R2) zaten 'https://...' → olduğu gibi döner.
/// Local dev'de '/uploads/...' (relatif) → API origin'i ile birleştirilir.
String? absoluteMediaUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('http')) return url;
  final origin = Uri.parse(Env.apiBaseUrl).origin;
  return '$origin$url';
}
