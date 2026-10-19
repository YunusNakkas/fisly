# Fişly — Store Submit Checklist (TestFlight + Play Internal)

Listing metinleri: [listing.md](listing.md). Bundle id: `com.fisly.app` (her iki platform).
Sürüm: `1.0.0+1` (pubspec). Uygulama adı: **Fişly** (iOS + Android'de düzeltildi).

> **Prod build flag'leri (her store build'inde ZORUNLU):** API base URL `--dart-define` ile gelir,
> aksi halde `localhost`'a bağlanır. Tüm release build'lerinde ekle:
> ```
> --dart-define=API_BASE_URL=https://fisly-backend.fly.dev/api/v1 \
> --dart-define=ENV=production \
> --dart-define=SENTRY_DSN=https://...
> ```

---

## 1. App Icon (yapılacak — tasarım gerekiyor)
Config `pubspec.yaml`'da hazır (`flutter_launcher_icons`). Üretmek için:
```bash
# 1024x1024 px, ŞEFFAF OLMAYAN ikonu koy:
#   mobile/assets/icon/app_icon.png
#   mobile/assets/icon/app_icon_foreground.png  (Android adaptive ön plan, şeffaf PNG)
cd mobile
flutter pub run flutter_launcher_icons
```
Gereksinimler:
- App Store: 1024×1024, köşe yuvarlatma YOK, alfa/şeffaflık YOK.
- Play Store: 512×512 mağaza ikonu + adaptive icon (üstteki config üretir).

## 2. Ekran Görselleri (yapılacak — cihazda çek)
Önerilen ekranlar: Dashboard (aylık özet), Fiş tarama sonucu, Harcama listesi/filtre, Bütçe, Abonelikler.

**iOS (App Store — zorunlu boyutlar):**
- 6.9" (iPhone 16 Pro Max) — 1320×2868 veya 1290×2796
- 6.5" (iPhone 11 Pro Max / XS Max) — 1242×2688
- iPad gönderilecekse 12.9" — 2048×2732
- En az 1, en çok 10 görsel.

**Android (Play — zorunlu):**
- Telefon: en az 2 görsel, 1080×1920 (veya 16:9/9:16, min kenar 320px).
- **Feature graphic: 1024×500** (zorunlu, banner).

> İpucu: `flutter run` ile simülatörde aç, görselleri çek; üstüne kısa TR başlık ekle (örn. "Fişini tara, harcaman kaydedilsin").

## 3. iOS — TestFlight
1. Apple Developer Program üyeliği aktif ($99/yıl).
2. App Store Connect → **My Apps → +** → bundle id `com.fisly.app`, dil TR.
3. Xcode'da `Runner` → Signing & Capabilities → Team seç, otomatik signing.
4. Versiyon/build ayarla, **Product → Archive** → **Distribute → App Store Connect**.
   - Alternatif CLI: `flutter build ipa --dart-define=API_BASE_URL=https://fisly-backend.fly.dev/api/v1 --dart-define=ENV=production` sonra Transporter ile yükle.
5. App Store Connect → TestFlight → build işlenince **Internal Testing** grubuna ekle (review'sız, 100 kişiye kadar).
6. **Export Compliance:** standart HTTPS şifreleme → genelde "muaf"; `ITSAppUsesNonExemptEncryption=false` Info.plist'e eklenebilir (soruyu atlatır).

## 4. Android — Play Internal Testing
1. Google Play Developer hesabı (tek seferlik $25).
2. **Upload key** oluştur. Gradle wiring **hazır** (`build.gradle.kts` → `key.properties` okur, yoksa debug'a düşer). Sadece keystore üret + `android/key.properties` doldur:
   ```bash
   keytool -genkey -v -keystore ~/keys/fisly-upload.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   cp android/key.properties.example android/key.properties   # değerleri doldur
   ```
3. `flutter build appbundle --dart-define=API_BASE_URL=https://fisly-backend.fly.dev/api/v1 --dart-define=ENV=production` → `build/app/outputs/bundle/release/app-release.aab`.
4. Play Console → Uygulama oluştur → **Test → Internal testing** → AAB yükle → test kullanıcısı e-postaları ekle.

## 5. App Privacy / Veri Güvenliği Formları (KVKK ile tutarlı)
[gizlilik_politikasi.md](../legal/gizlilik_politikasi.md) ile **birebir tutarlı** doldur.
Topladığımız ve "uygulamaya bağlı" işaretlenecek veriler:
- İletişim: e-posta (hesap yönetimi).
- Kullanıcı içeriği: fiş görselleri (uygulama işlevi).
- Finansal bilgi: harcama/abonelik verileri (uygulama işlevi). **Banka/kart bilgisi YOK.**
- Tanımlayıcılar: kullanıcı ID.
- Teşhis: çökme/performans (Sentry).
- **Veri satışı: HAYIR.** Üçüncü taraf işleyenler: Google (OCR), Cloudflare, Fly.io, Sentry.

## 6. Review için kritik notlar
- **Hesap silme:** App Store Guideline 5.1.1(v) — uygulama içi hesap silme **var** (Ayarlar → Hesabı sil → `DELETE /auth/me`). Review notuna belirt.
- **Demo hesap:** review ekibine test e-postası/şifresi ver (App Review Information → Sign-in required).
- **İçerik derecelendirmesi:** 4+ / Everyone (finans, hassas içerik yok).
- **Yaş:** uygulama 18+ hedefli (gizlilik politikası madde 7) — derecelendirme anketinde belirt.

## 7. Son kontroller (kod tarafı)
- [x] Uygulama adı "Fişly" (iOS CFBundleDisplayName + Android label).
- [ ] Gerçek app icon üretildi (adım 1).
- [ ] Release build'leri `--dart-define=API_BASE_URL=...` ile prod'a bağlanıyor (default localhost!).
- [ ] Android release imzası yapılandırıldı (adım 4.2).
- [ ] Gizlilik politikası `https://fisly.app/privacy`'de yayında.
- [ ] Backend prod'da çalışıyor (docs/deploy_fly.md).
