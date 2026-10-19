import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/env.dart';

/// RevenueCat'te tanımlı entitlement kimliği (premium erişimi).
const String premiumEntitlementId = 'premium';

String get _apiKey =>
    Platform.isIOS ? Env.revenueCatApiKeyApple : Env.revenueCatApiKeyGoogle;

/// Anahtar tanımlı değilse IAP devre dışı (dev/test ortamı çökmesin).
bool get billingEnabled => _apiKey.isNotEmpty;

/// Uygulama açılışında bir kez çağrılır.
Future<void> configureRevenueCat() async {
  if (!billingEnabled) return;
  await Purchases.setLogLevel(LogLevel.warn);
  await Purchases.configure(PurchasesConfiguration(_apiKey));
}

/// Giriş yapan kullanıcının backend UUID'sini RevenueCat'e bağlar.
/// Webhook'lar bu app_user_id ile gelir → backend planı günceller.
Future<void> billingLogIn(String userId) async {
  if (!billingEnabled) return;
  try {
    await Purchases.logIn(userId);
  } catch (_) {
    // IAP yapılandırılmamışsa veya ağ hatasında sessiz geç.
  }
}

Future<void> billingLogOut() async {
  if (!billingEnabled) return;
  try {
    await Purchases.logOut();
  } catch (_) {}
}
