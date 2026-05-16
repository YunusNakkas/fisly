# Architecture Decision Records

Her ADR: bağlam → karar → gerekçe → sonuçlar.

---

## ADR-001: Backend Framework — FastAPI

**Tarih:** 2026-05-07
**Durum:** Kabul edildi

### Bağlam
Mobil uygulama için REST API gerekiyor. Geliştirici Python biliyor, ekstra dil öğrenme maliyeti istenmiyor.

### Karar
Backend olarak **FastAPI** kullanılacak.

### Gerekçe
- Geliştirici FastAPI ile önceki projelerde deneyim kazandı (akilli-akademik-asistan).
- Python ekosistemi, Gemini API ve diğer AI kütüphaneleriyle sıfır sürtünme.
- Async native, performans yeterli.
- Otomatik OpenAPI dökümantasyonu geliştirme hızını artırıyor.

### Sonuçlar
- Django REST Framework, Node.js/Express değerlendirilmeyecek.
- SQLAlchemy 2.x (async) ile birlikte kullanılacak.

---

## ADR-002: Mobil Framework — Flutter

**Tarih:** 2026-05-07
**Durum:** Kabul edildi

### Bağlam
iOS ve Android'i desteklemek gerekiyor. Geliştirici ne Flutter ne React Native biliyor; öğrenme maliyeti kaçınılmaz.

### Karar
Mobil için **Flutter** kullanılacak.

### Gerekçe
- Tek kod tabanıyla iOS + Android + Web (ileride).
- React Native'e göre Dart öğrenmek Python geçmişiyle daha doğal (strong typed).
- Flutter'ın widget sistemi, özelleştirilmiş finans UI'ı için daha kontrollü.
- Vibe coding ile AI yardımı ile öğrenilmesi planlanıyor, fark küçülüyor.

### Sonuçlar
- React Native kullanılmayacak.
- Native iOS/Swift veya Android/Kotlin yazılmayacak.
- State management olarak **Riverpod** seçildi (provider bağımlılığı yok, test edilebilir).

---

## ADR-003: Veritabanı — PostgreSQL

**Tarih:** 2026-05-07
**Durum:** Kabul edildi

### Bağlam
Kullanıcı, harcama, kategori ve abonelik verisi ilişkisel. Finansal verinin tutarlılığı kritik.

### Karar
**PostgreSQL** kullanılacak.

### Gerekçe
- İlişkisel sorgular (JOIN, aggregate) MongoDB'ye göre çok daha güçlü.
- ACID garantisi finansal veri için zorunlu.
- JSONB tipi fiş ham OCR verisi için esnek alan sağlıyor.
- SQLAlchemy 2.x async ile doğal entegrasyon.

### Sonuçlar
- MongoDB, SQLite (production için) değerlendirilmeyecek.
- Para birimleri `NUMERIC(12,2)` ile saklanacak, `FLOAT` asla kullanılmayacak.
- Migration yönetimi **Alembic** ile yapılacak.

---

## ADR-004: Fiş OCR — Gemini Vision API

**Tarih:** 2026-05-07
**Durum:** Kabul edildi

### Bağlam
Türkçe fişlerden tarih, market adı, ürün listesi ve toplam tutarın otomatik çekilmesi gerekiyor. Farklı font, kötü ışık ve buruşuk kağıt gibi varyasyonlar var.

### Karar
OCR için **Gemini Vision API** kullanılacak.

### Gerekçe
- Geliştirici Gemini API ile daha önce çalıştı (öğrenme süreci yok).
- Prompt mühendisliği ile Türkçe fiş formatlarına uyarlanabilir.
- Fine-tune gerektirmiyor; genel amaçlı vision model yeterli doğruluk sağlıyor.
- Google Cloud Vision ayrı servis maliyeti getiriyor, Gemini her ikisini karşılıyor.

### Sonuçlar
- Tesseract, AWS Textract, Azure OCR değerlendirilmeyecek.
- API anahtarı sadece backend'de tutulacak, mobil istemciye asla açılmayacak.
- Kullanıcı başına aylık fiş tarama kotası konacak (maliyet kontrolü).
- OCR başarısız olduğunda kullanıcı manuel düzenleme yapabilecek.

---

## ADR-005: Kimlik Doğrulama — JWT (Access + Refresh Token)

**Tarih:** 2026-05-07
**Durum:** Kabul edildi

### Bağlam
Mobil uygulama için stateless auth gerekiyor. Kullanıcı her seferinde login olmak istemiyor.

### Karar
**JWT** tabanlı auth: kısa ömürlü access token + uzun ömürlü refresh token.

### Gerekçe
- Stateless — sunucu tarafında session store yok, horizontal scale kolaylaşıyor.
- Mobil için standart pattern.
- Access token süresi kısa (15 dk) → çalınsa dahi sınırlı hasar.
- Refresh token rotate edilecek → uzun oturum + güvenlik dengesi.

### Sonuçlar
- Session-based auth kullanılmayacak.
- Şifreler **bcrypt** ile hash'lenecek (worköyle ≥ 12).
- Token'lar mobilde **flutter_secure_storage** ile saklanacak (SharedPreferences değil).
- `/auth/login` ve `/auth/refresh` endpoint'lerine rate limiting uygulanacak.

---

## ADR-006: Fiş Görsel Depolama — Cloud Object Storage

**Tarih:** 2026-05-07
**Durum:** Kabul edildi

### Bağlam
Kullanıcılar fiş fotoğrafı yükleyecek. Bu görsellerin uzun vadeli saklanması ve cihaz değişiminde erişilebilir olması gerekiyor.

### Karar
Fiş görselleri **S3-uyumlu object storage**'a yüklenecek (Cloudflare R2 veya AWS S3).

### Gerekçe
- Görseller sunucu diskinde tutulursa disk dolumu ve yedekleme sorunu olur.
- R2, S3 ile uyumlu ama egress ücreti yok — maliyet avantajı.
- Kullanıcı cihaz değiştirdiğinde görseller erişilebilir kalır.

### Sonuçlar
- Görseller DB'de değil, storage'da tutulacak; DB'de sadece URL.
- MVP'de lokal disk + opsiyonel cloud backup yeterli, production'da R2/S3'e geçilecek.
- Upload max 5MB, MIME tipi kontrol edilecek (image/jpeg, image/png, image/webp).
- Presigned URL ile doğrudan mobil → storage upload değerlendirilecek (backend yük azaltma).

---

## ADR-007: Fiş İşleme Yeri — Server-side

**Tarih:** 2026-05-07
**Durum:** Kabul edildi

### Bağlam
Fiş görseli Gemini Vision'a gönderilebilir. Bu işlem client'ta (mobilde) veya server'da yapılabilir.

### Karar
Gemini API çağrısı **backend'de** yapılacak.

### Gerekçe
- Gemini API anahtarı mobil uygulamada olursa decompile ile çalınabilir.
- Kota ve maliyet kontrolü sadece server tarafında mümkün.
- OCR sonucunun DB'ye yazılması zaten server'da olacak, round-trip azaltıyor.

### Sonuçlar
- Mobil görüntüyü backend'e POST eder, backend Gemini'ye gönderir, parse eder, DB'ye yazar, sonucu döner.
- Timeout riski var (büyük görüntü + yavaş Gemini): mobil tarafında loading state ve timeout handling zorunlu.

---

## ADR-008: Connectivity Stratejisi — Online-first (MVP)

**Tarih:** 2026-05-07
**Durum:** Kabul edildi

### Bağlam
Offline-first mimarisi (yerel SQLite + sync) kullanıcı deneyimini artırır ama CRDT / conflict resolution karmaşıklığı MVP süresini ciddi uzatır.

### Karar
MVP **online-first** olacak; offline mod desteklenmeyecek.

### Gerekçe
- Solo geliştirici + vibe coding sürecinde sync çakışma çözümü orantısız karmaşıklık getirir.
- Hedef kullanıcı profili (%95 zaman internet erişimi olan şehirli bireyler) için offline mod kritik değil.
- Hız: önce traction topla, sonra ihtiyaç gerçekleşirse offline ekle.

### Sonuçlar
- Flutter tarafında local SQLite cache yapılmayacak (MVP için).
- İnternet yoksa kullanıcıya anlamlı hata mesajı gösterilecek.
- İlerideki versiyonda: Drift (Flutter SQLite ORM) + background sync değerlendirilebilir.
