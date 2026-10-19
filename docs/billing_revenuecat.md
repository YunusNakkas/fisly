# Ödeme — RevenueCat + IAP Kurulumu

Premium = **dijital abonelik** → Apple/Google **IAP zorunlu** (iyzico/Stripe reddedilir).
Aylık + Yıllık abonelik. Akış: mobil RevenueCat ile satın alma → RevenueCat webhook → backend `user.plan` günceller.

## Kod tarafı (BİTTİ)
**Backend**
- `POST /api/v1/billing/webhook` — RevenueCat olaylarını işler, Authorization header'ı `REVENUECAT_WEBHOOK_AUTH` ile doğrular.
  - Premium ver: INITIAL_PURCHASE, RENEWAL, UNCANCELLATION, PRODUCT_CHANGE, NON_RENEWING_PURCHASE
  - Premium al: EXPIRATION
  - CANCELLATION → plan değişmez (abonelik bitene kadar premium kalır)
- `users.premium_expires_at` kolonu + migration (`a1b2c3d4e012`).
- `/auth/me` artık `plan` + `premium_expires_at` döner. Kota mantığı zaten `plan==premium` → sınırsız.

**Mobil**
- `core/billing/billing_service.dart` — configure, logIn(userUUID), logOut.
- `features/premium/premium_provider.dart` — canlı premium durumu (RevenueCat CustomerInfo).
- `features/premium/presentation/paywall_screen.dart` — `/premium` route'u; offering'leri listeler, satın alma + restore.
- Ayarlar'da premium upsell kartı (premium değilse).
- Login/register/bootstrap → `Purchases.logIn(userId)`; logout/delete → `logOut()`.

## Senin yapacakların

### 1. RevenueCat dashboard
1. Proje oluştur, iOS + Android app'lerini ekle.
2. **Entitlement** oluştur: kimlik `premium` (kodda `premiumEntitlementId` ile aynı olmalı).
3. **Products**: App Store Connect + Play Console'da iki abonelik ürünü tanımla (aylık, yıllık), RevenueCat'e bağla.
4. **Offering** (`default`) oluştur, monthly + annual paketleri ekle.
5. **Public SDK API key**'leri al (Apple: `appl_...`, Google: `goog_...`).
6. **Webhook** ekle: URL `https://fisly-backend.fly.dev/api/v1/billing/webhook`, Authorization header'a bir secret yaz.

### 2. Store ürünleri
- **App Store Connect:** Subscriptions group → 2 ürün (ör. `fisly_premium_monthly`, `fisly_premium_yearly`), fiyat kademesi, lokalize ad/açıklama. Abonelik için **paywall metni + gizlilik + kullanım şartları linkleri** zorunlu (review).
- **Play Console:** Monetize → Subscriptions → 2 base plan (aylık/yıllık).

### 3. Backend secret (Fly)
```bash
fly secrets set REVENUECAT_WEBHOOK_AUTH="<dashboard'a yazdığın secret>"
```

### 4. Mobil build (RevenueCat anahtarlarıyla)
```bash
flutter build appbundle \
  --dart-define=API_BASE_URL=https://fisly-backend.fly.dev/api/v1 \
  --dart-define=ENV=production \
  --dart-define=REVENUECAT_API_KEY_APPLE=appl_xxx \
  --dart-define=REVENUECAT_API_KEY_GOOGLE=goog_xxx
```
> Anahtar verilmezse IAP otomatik devre dışı kalır (uygulama çökmez, paywall "kullanılamıyor" der).

## Test
- Backend: `tests/test_billing.py` — grant/expire/auth/unknown-user (4 test).
- Mobil: gerçek satın alma **sandbox** ile test edilir (App Store sandbox tester + Play internal testing). Simülatörde IAP çalışmaz; gerçek cihaz/sandbox gerekir.

## Review notları
- Apple: abonelik açıklaması, otomatik yenileme ifadesi, fiyat, gizlilik + şartlar linkleri paywall'da görünmeli (paywall_screen bunu içeriyor; linkleri store şartına göre genişletebilirsin).
- "Restore purchases" butonu zorunlu → var.
