# Fişly — CLAUDE.md

## Proje Genel Bakış

**Fişly**, Türkçe lokalize bir kişisel finans uygulamasıdır. Kullanıcılar fiş fotoğraflarını tarayarak harcamalarını otomatik kaydeder, kategorilere ayırır ve abonelik/tekrarlayan ödemelerini takip eder. Hedef: "Maaşım girdi, ay sonunda nereye gitti bilmiyorum" sorununu çözmek.

**Diferansiyatör:** Manuel giriş zahmetini fiş OCR ile ortadan kaldırmak. Türkiye pazarı için lokalize (TL, Türk market zincirleri, Türkçe fiş formatları).

**Hedef kitle:** 25-40 yaş, düzenli geliri olan, harcamalarını kontrol etmek isteyen bireyler.

**İş modeli:** Freemium — ücretsiz planda sınırlı fiş/ay, premium'da sınırsız + raporlar + export.

---

## Mimari Kararlar ve Gerekçeleri

### 1. Backend: FastAPI
- **Neden:** Geliştirici zaten FastAPI biliyor, Python ekosistemi Gemini API ile kolay entegre.
- **Alternatif değil:** Node.js (öğrenme maliyeti), Django (overkill — REST API odaklıyız).

### 2. Mobil: Flutter
- **Neden:** Tek kod tabanı ile iOS + Android. Web'e de derlenebiliyor (ileride PWA opsiyonu).
- **Tradeoff:** Geliştirici Flutter bilmiyor, öğrenme süreci olacak. Vibe coding ile destekli ilerlenecek.
- **Alternatif değil:** React Native (geliştirici React de bilmiyor, fark yok), Kotlin/Swift native (iki kez yazma maliyeti).

### 3. Veritabanı: PostgreSQL
- **Neden:** İlişkisel veri (kullanıcı → kategori → harcama), ACID gereklilik (finansal veri), JSONB desteği (fiş raw data için).
- **Alternatif değil:** MongoDB (ilişkisel sorgular zayıf), SQLite (multi-user değil).

### 4. OCR: Gemini Vision API
- **Neden:** Geliştirici tecrübesi var. Fine-tune gerektirmiyor, prompt mühendisliği ile Türkçe fiş okuma yapılabilir.
- **Tradeoff:** API maliyeti var (~$0.001-0.002/fiş). Kullanıcı başına aylık limit konacak.
- **Alternatif değil:** Tesseract (Türkçe doğruluk düşük), Google Cloud Vision (Gemini zaten yapıyor, ek servis gereksiz).

### 5. Auth: JWT + Refresh Token
- **Neden:** Stateless, mobil için ideal. FastAPI'de standart pattern.
- **Şifre:** bcrypt hash, asla plaintext.

### 6. Storage: Cloud (S3-uyumlu)
- **Neden:** Fiş görselleri kullanıcı cihazını şişirmesin. Cihaz değiştirmede senkronizasyon kolay.
- **MVP'de:** Local storage + opsiyonel cloud backup. Üretimde S3/R2.

### 7. Fiş İşleme: Server-side
- **Neden:** Gemini API key client'ta ifşa olmamalı. Maliyet kontrolü merkezde olmalı.
- **Akış:** Mobil → image upload → Backend → Gemini → parse → DB → response.

### 8. Offline-first değil, online-first
- **Neden:** MVP'yi basit tutmak için. Sync çakışma çözümü (CRDT vb.) karmaşık.
- **İleride:** SQLite local cache + background sync.

---

## Klasör Yapısı

```
fişly/
├── backend/
│   ├── app/
│   │   ├── main.py                 # FastAPI giriş noktası
│   │   ├── config.py               # Env değişkenleri (Pydantic Settings)
│   │   ├── database.py             # SQLAlchemy session
│   │   ├── models/                 # SQLAlchemy modelleri
│   │   │   ├── user.py
│   │   │   ├── expense.py
│   │   │   ├── category.py
│   │   │   ├── subscription.py
│   │   │   └── receipt.py
│   │   ├── schemas/                # Pydantic request/response şemaları
│   │   ├── routers/                # API endpoint'leri
│   │   │   ├── auth.py
│   │   │   ├── expenses.py
│   │   │   ├── receipts.py
│   │   │   ├── subscriptions.py
│   │   │   ├── categories.py
│   │   │   └── reports.py
│   │   ├── services/               # İş mantığı
│   │   │   ├── ocr_service.py      # Gemini Vision wrapper
│   │   │   ├── auth_service.py     # JWT, password hash
│   │   │   └── budget_service.py   # Bütçe hesaplama
│   │   ├── core/
│   │   │   ├── security.py         # JWT helpers
│   │   │   └── deps.py             # FastAPI dependencies (get_current_user)
│   │   └── utils/
│   ├── alembic/                    # Migration'lar
│   ├── tests/
│   ├── requirements.txt
│   └── .env.example
│
├── mobile/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart
│   │   ├── core/
│   │   │   ├── api/                # Dio client, interceptor
│   │   │   ├── storage/            # Secure storage (token)
│   │   │   ├── theme/
│   │   │   └── router/             # GoRouter konfig
│   │   ├── features/               # Feature-first organizasyon
│   │   │   ├── auth/
│   │   │   │   ├── data/
│   │   │   │   ├── domain/
│   │   │   │   └── presentation/
│   │   │   ├── receipts/
│   │   │   ├── expenses/
│   │   │   ├── subscriptions/
│   │   │   ├── budget/
│   │   │   └── reports/
│   │   └── shared/                 # Ortak widget'lar
│   ├── assets/
│   ├── pubspec.yaml
│   └── test/
│
├── docs/
│   ├── api.md
│   └── decisions.md                # ADR (architecture decision records)
│
├── docker-compose.yml              # PostgreSQL + backend lokal
├── .gitignore
├── README.md
└── CLAUDE.md
```

---

## API Endpoint Planı

Tüm endpoint'ler `/api/v1` prefix altında. JWT gerektirenler `🔒` ile işaretli.

### Auth
- `POST /auth/register` — email + şifre kayıt
- `POST /auth/login` — JWT access + refresh token döner
- `POST /auth/refresh` — refresh token ile yeni access token
- `POST /auth/logout` 🔒
- `GET /auth/me` 🔒 — mevcut kullanıcı bilgisi

### Receipts (Fiş)
- `POST /receipts/scan` 🔒 — multipart image upload, Gemini'ye gönder, parse et, expense oluştur
- `GET /receipts` 🔒 — kullanıcının fişleri (paginated)
- `GET /receipts/{id}` 🔒
- `DELETE /receipts/{id}` 🔒
- `PATCH /receipts/{id}` 🔒 — OCR yanlış okuduysa düzeltme

### Expenses (Harcama)
- `POST /expenses` 🔒 — manuel harcama girişi (fişsiz)
- `GET /expenses` 🔒 — filtre: ?category=&from=&to=&min=&max=
- `GET /expenses/{id}` 🔒
- `PATCH /expenses/{id}` 🔒
- `DELETE /expenses/{id}` 🔒

### Categories
- `GET /categories` 🔒 — sistem + kullanıcı kategorileri
- `POST /categories` 🔒 — özel kategori oluştur
- `PATCH /categories/{id}` 🔒
- `DELETE /categories/{id}` 🔒

### Subscriptions
- `GET /subscriptions` 🔒
- `POST /subscriptions` 🔒 — ad, tutar, periyot, başlangıç tarihi
- `PATCH /subscriptions/{id}` 🔒
- `DELETE /subscriptions/{id}` 🔒
- `POST /subscriptions/{id}/cancel` 🔒 — iptal işaretle (geçmişe dokunma)

### Budget
- `GET /budgets` 🔒
- `POST /budgets` 🔒 — kategori bazlı veya genel aylık limit
- `PATCH /budgets/{id}` 🔒
- `DELETE /budgets/{id}` 🔒

### Reports
- `GET /reports/summary` 🔒 — ?period=monthly|weekly — toplam, kategori dağılımı
- `GET /reports/category-breakdown` 🔒 — pasta grafik için
- `GET /reports/trends` 🔒 — aylık trend (son 6 ay)
- `GET /reports/insights` 🔒 — AI içgörüler (Gemini ile, premium)

---

## Veritabanı Şeması

### users
| kolon | tip | notlar |
|---|---|---|
| id | UUID PK | |
| email | VARCHAR UNIQUE | |
| password_hash | VARCHAR | bcrypt |
| full_name | VARCHAR NULL | |
| plan | ENUM(free, premium) | default 'free' |
| receipt_quota_used | INT | aylık reset |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

### categories
| kolon | tip | notlar |
|---|---|---|
| id | UUID PK | |
| user_id | UUID FK NULL | NULL = sistem kategorisi |
| name | VARCHAR | "Market", "Ulaşım", vs. |
| icon | VARCHAR | icon adı/kodu |
| color | VARCHAR(7) | hex |
| is_system | BOOLEAN | |

### expenses
| kolon | tip | notlar |
|---|---|---|
| id | UUID PK | |
| user_id | UUID FK | INDEX |
| category_id | UUID FK | |
| receipt_id | UUID FK NULL | manuel girişlerde NULL |
| amount | NUMERIC(12,2) | |
| currency | VARCHAR(3) | default 'TRY' |
| merchant | VARCHAR NULL | |
| note | TEXT NULL | |
| spent_at | TIMESTAMPTZ | INDEX |
| created_at | TIMESTAMPTZ | |

### receipts
| kolon | tip | notlar |
|---|---|---|
| id | UUID PK | |
| user_id | UUID FK | |
| image_url | VARCHAR | storage path |
| raw_ocr_data | JSONB | Gemini'den gelen ham yanıt |
| merchant | VARCHAR NULL | |
| total_amount | NUMERIC(12,2) NULL | |
| receipt_date | DATE NULL | |
| status | ENUM(pending, parsed, failed, manual) | |
| created_at | TIMESTAMPTZ | |

### receipt_items (opsiyonel — MVP'de basit tut)
| kolon | tip | notlar |
|---|---|---|
| id | UUID PK | |
| receipt_id | UUID FK | |
| name | VARCHAR | |
| quantity | NUMERIC NULL | |
| unit_price | NUMERIC NULL | |
| total | NUMERIC | |

### subscriptions
| kolon | tip | notlar |
|---|---|---|
| id | UUID PK | |
| user_id | UUID FK | |
| name | VARCHAR | "Netflix", "Spotify" |
| amount | NUMERIC(12,2) | |
| currency | VARCHAR(3) | |
| period | ENUM(monthly, yearly, weekly) | |
| start_date | DATE | |
| next_billing_date | DATE | INDEX (hatırlatıcı için) |
| status | ENUM(active, cancelled) | |
| category_id | UUID FK NULL | |

### budgets
| kolon | tip | notlar |
|---|---|---|
| id | UUID PK | |
| user_id | UUID FK | |
| category_id | UUID FK NULL | NULL = genel bütçe |
| amount | NUMERIC(12,2) | |
| period | ENUM(monthly, weekly) | |
| starts_on | DATE | |

**Indeksler:**
- `expenses(user_id, spent_at DESC)` — listeleme için
- `expenses(user_id, category_id)` — rapor için
- `subscriptions(user_id, next_billing_date)` — bildirim cron'u için

---

## Kodlama Kuralları

### Genel
- Türkçe yorumlar OK, ama kod (değişken/fonksiyon adları) İngilizce.
- Para birimi her zaman `NUMERIC` (asla `FLOAT` — yuvarlama hataları finansal veride kabul edilemez).
- Tarih/saat her zaman `TIMESTAMPTZ` (UTC sakla, gösterimde TR saatine çevir).
- UUID kullan, integer ID değil (mobil sync ve güvenlik için).

### Backend (Python/FastAPI)
- Type hint zorunlu (`def foo(x: int) -> str`).
- Pydantic v2 — request/response şemaları ayrı tut (`UserCreate`, `UserResponse`).
- Async endpoint'ler — DB için `asyncpg` veya SQLAlchemy async.
- Secrets `.env` üzerinden, `Settings(BaseSettings)` ile oku.
- Gemini API çağrıları `services/ocr_service.py` içinde — endpoint'lerde direkt çağrılmaz.
- Hata yönetimi: domain hataları için custom exception, FastAPI exception handler ile JSON response.

### Mobile (Flutter/Dart)
- Feature-first klasör yapısı (auth/, receipts/, ...).
- State management: Riverpod (basit, modern, test edilebilir).
- HTTP client: Dio + interceptor (token refresh otomatik).
- Form validation: form_builder_validators.
- Lokalizasyon: Türkçe başla, sonradan EN ekle (intl + .arb).

### Güvenlik
- Asla şifre veya API key commit etme. `.gitignore` doğru kur.
- JWT access token kısa (15 dk), refresh token uzun (30 gün, rotate).
- Rate limit: `/auth/login` ve `/receipts/scan` üzerinde (slowapi ile).
- File upload: MIME type kontrolü, max 5MB, image-only.

### Git
- Branch: `main` (stable), `dev` (entegrasyon), feature branch: `feat/...`, fix: `fix/...`.
- Commit: conventional commits (`feat:`, `fix:`, `chore:`).
- PR yerine küçük, sık commit (solo developer için yeterli).

---

## MVP Scope

### MVP'de VAR
- Kullanıcı kayıt/giriş (email + şifre, JWT)
- Manuel harcama girişi (tutar, kategori, tarih, not)
- Sistem kategorileri (Market, Ulaşım, Faturalar, Yeme-İçme, Sağlık, Eğlence, Diğer)
- Fiş tarama (kameradan veya galeriden) → Gemini Vision → otomatik harcama oluştur
- OCR sonucu kullanıcının düzenleyebilmesi
- Harcama listesi (filtre: tarih aralığı, kategori)
- Aylık özet ekranı (toplam + kategori bazlı pasta grafik)
- Aylık bütçe limiti (genel) — aşıldığında uygulama içi uyarı
- Manuel abonelik ekleme + sonraki ödeme tarihi gösterimi

### MVP'de YOK (sonraki versiyonlar)
- Banka entegrasyonu / hesap ekstresi parse
- AI içgörüler ("market harcaman %30 arttı")
- Aile/eş paylaşımlı bütçe
- Push notification (sadece in-app uyarı MVP'de)
- Web uygulaması
- PDF/Excel export
- Çoklu para birimi (sadece TRY)
- Offline mod
- Otomatik abonelik tespiti
- Premium plan (önce ücretsiz dağıt, traction sonra paywall)
- Sosyal özellikler / paylaşım

### MVP başarı kriterleri
- 50 gerçek kullanıcı (arkadaş/aile dışı)
- Kullanıcı başına haftada en az 3 fiş tarama
- 30-day retention > %20

---

## Geliştirme Akışı (Vibe Coding Notları)

1. **Önce mimari konuş, sonra kod yaz.** Yeni feature başlamadan önce: hangi endpoint, hangi tablo, hangi ekran — bunu bu CLAUDE.md'ye ekle.
2. **Küçük adımlarla ilerle.** Bir feature = 1-2 endpoint + 1 ekran + test. Hepsi çalışmadan diğerine geçme.
3. **Çalışır halini commit et.** Bozuk kodu commit etme, bozuksa önce düzelt.
4. **Her API çağrısını manuel test et** (Postman/Bruno). Mobil tarafa geçmeden önce backend doğru çalışmalı.
5. **AI'ya tek seferde her şeyi sorma.** "Auth sistemi yap" yerine "JWT access token oluşturan endpoint yap". Parça parça.
6. **Mimariyle çelişen öneriyi reddet.** AI bazen bu dosyayla uyuşmayan önerirse, dosyayı referans göster ya da düzelt.

---

## Önemli Komutlar (lokal geliştirme)

```bash
# Backend
cd backend
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
alembic upgrade head
uvicorn app.main:app --reload

# Mobile
cd mobile
flutter pub get
flutter run

# DB (Docker)
docker-compose up -d postgres
```

---

## Açık Kararlar (sonra netleşecek)

- [ ] Push notification servisi (FCM mi, OneSignal mı?)
- [ ] Production hosting (Railway / Fly.io / DigitalOcean?)
- [ ] Domain ve SSL (Cloudflare?)
- [ ] App Store / Play Store yayın stratejisi (önce TestFlight/internal testing)
- [ ] Premium fiyatlandırma (₺49/ay? Yıllık indirim?)
- [ ] Gemini API maliyet limiti (kullanıcı başına aylık fiş tavanı)
